# supported connections

supported_db_connections <- c("SQLiteConnection", "MySQLConnection",
                              "MariaDBConnection", "PostgreSQLConnection")

#' check validity of the user table
#' @param user_data data.frame with the user data
#' @noRd

check_user_data <- function(user_data) {
  
  if (class(user_data) != "data.frame") {
    stop(call. = F, "User data need to be in form of 'data.frame' object.")
  }
  if (!all(c("username", "password", "email") %in% names(user_data))) {
    stop(call. = F, "Data.frame containing user data needs to contain columns: 'username', 'password' and 'email'.")
  }
  if (sum(is.na(user_data$username), is.na(user_data$password), is.na(user_data$email)) > 0) {
    stop(call. = F, "Provided user data can't contain any NA values.")
  }
}


#' Create RegLog-valid database tables with DBI
#' 
#' @param conn DBI connection object
#' @param user_name Name of the table for storing user credentials. Defaults to
#' 'user'. Mandatory table.
#' @param reset_code_name Name of the table for storing generated password reset
#' codes. Defaults to 'reset_code'. Mandatory table.
#' @param use_log Should the table for keeping RegLogServer logs be 
#' also created? Defaults to FALSE
#' @param log_name Name of the table for storing logs from RegLogServer object.
#' Used only if `use_log = TRUE`. Defaults to `logs`
#' @param user_data If you wish to import existing user database, you can input
#' data.frame with that table in this argument. It should contain columns:
#' username, password, email. Defaults to NULL.
#' @param hash_passwords If you are importing table of users upon tables creation,
#' you can also specify if the password should be hashed using `scrypt::hashPassword`.
#' Defaults to `FALSE`. If you have unhashed passwords in imported table, set
#' this option to `TRUE`.
#' @param verbose Boolean specific if the actions made by function should be
#' printed back to the console. Defaults to `TRUE`.
#' 
#' @details Currently, the function is tested and working correctly for
#' SQLite, MySQL, MariaDB and PostrgreSQL databases. If you want to use another 
#' DBI-supported database, you need to create tables in other ways. 
#' 
#' Created tables should have following structure:
#' 
#' - user (default name)
#'   - id: integer, primary key, auto-increment
#'   - username: varchar(255), NOT NULL, unique
#'   - password: varchar(255), NOT NULL
#'   - email: varchar(255), NOT NULL, unique
#'   - create_time: datetime, NOT NULL
#'   - update_time: datetime, NOT NULL
#' - reset_code (default name)
#'   - id: integer, primary key, auto-increment
#'   - user_id: integer, NOT NULL
#'   - reset_code: varchar(10), NOT NULL
#'   - used: tinyint, NOT NULL
#'   - create_time: datetime, NOT NULL
#'   - update_time: datetime, NOT NULL
#' - logs (default name, optional)
#'   - id: integer, primary key, auto-increment
#'   - time: datetime, NOT NULL
#'   - session: varchar(255), NOT NULL
#'   - direction: varchar(255), NOT NULL
#'   - type: varchar(255), NOT NULL
#'   - note: varchar(255)
#' 
#' @return List with results of the creation
#' @example examples/DBI_tables_create.R
#' @export
#' @family RegLog databases

DBI_tables_create <- function(
  conn,
  user_name = "user",
  reset_code_name = "reset_code",
  use_log = FALSE,
  log_name = "logs",
  user_data = NULL,
  hash_passwords = FALSE,
  verbose = TRUE
  ){
  # if user data is provided, check its validity
  if (!is.null(user_data)) {
    check_user_data(user_data)
  }
  
  # get the class of the SQL connection
  class <- class(conn)[1]
  
  if (!class %in% supported_db_connections) {
    stop(paste0("This function currently supports only database connections: ", 
               paste(collapse = ", ", supported_db_connections)), ".")
  }
  
  output <- list()
  
  # create user table
  
  output[["user"]][["table_name"]] <- user_name
  output[["user"]][["result"]] <- tryCatch(
    DBI::dbCreateTable(
      conn,
      user_name,
      c("id" = if (class == "SQLiteConnection") "INTEGER PRIMARY KEY"
        else if (class %in% c("MySQLConnection", "MariaDBConnection")) "INT PRIMARY KEY AUTO_INCREMENT"
        else if (class == "PostgreSQLConnection") "SERIAL PRIMARY KEY",
        "username" = "VARCHAR(255) NOT NULL UNIQUE",
        "password" = "VARCHAR(255) NOT NULL",
        "email" = "VARCHAR(255) NOT NULL UNIQUE",
        "create_time" = if (class == "PostgreSQLConnection") "TIMESTAMP NOT NULL" 
                      else "DATETIME NOT NULL",
        "update_time" = if (class == "PostgreSQLConnection") "TIMESTAMP NOT NULL" 
                      else "DATETIME NOT NULL"
    )),
    error = function(e) e,
    warning = function(w) w
  )
  
  if (isTRUE(verbose)) {
    writeLines(paste0(output$user$table_name, " creation result: ", output$user$result))
  }
  
  # create reset code table
  
  output[["reset_code"]][["table_name"]] <- reset_code_name
  output[["reset_code"]][["result"]] <- tryCatch(
    DBI::dbCreateTable(
      conn,
      reset_code_name,
      c("id" = if (class == "SQLiteConnection") "INTEGER PRIMARY KEY"
        else if (class %in% c("MySQLConnection", "MariaDBConnection")) "INT PRIMARY KEY AUTO_INCREMENT"
        else if (class == "PostgreSQLConnection") "SERIAL PRIMARY KEY",
        "user_id" = "INT NOT NULL",
        "reset_code" = "VARCHAR(10) NOT NULL",
        "used" = if (class == "PostgreSQLConnection") "SMALLINT NOT NULL" 
               else "TINYINT NOT NULL",
        "create_time" = if (class == "PostgreSQLConnection") "TIMESTAMP NOT NULL" 
                        else "DATETIME NOT NULL",
        "update_time" = if (class == "PostgreSQLConnection") "TIMESTAMP NOT NULL" 
                        else "DATETIME NOT NULL"
        )
      ),
    error = function(e) e,
    warning = function(w) w
  )
  
  if (isTRUE(verbose)) {
    writeLines(paste0(output$reset_code$table_name, " creation result: ", output$reset_code$result))
  }
  
  # optionally - create log-storing table
  
  if (isTRUE(use_log)) {

    output[["log"]][["table_name"]] <- log_name
    output[["log"]][["result"]] <- tryCatch(
      DBI::dbCreateTable(
        conn,
        log_name,
        c("id" = if (class == "SQLiteConnection") "INTEGER PRIMARY KEY"
          else if (class %in% c("MySQLConnection", "MariaDBConnection")) "INT PRIMARY KEY AUTO_INCREMENT"
          else if (class == "PostgreSQLConnection") "SERIAL PRIMARY KEY",
          "time" = if (class == "PostgreSQLConnection") "TIMESTAMP NOT NULL" 
                   else "DATETIME NOT NULL",
          "session" = "VARCHAR(255) NOT NULL",
          "direction" = "VARCHAR(255) NOT NULL",
          "type" = "VARCHAR(255) NOT NULL",
          "note" = "VARCHAR(255)")),
      error = function(e) e,
      warning = function(w) w
    )
    
    if (isTRUE(verbose)) {
      writeLines(paste0(output$log$table_name, " creation result: ", output$log$result))
    }
  }
  
  # optionally: insert user data
  if (!is.null(user_data)) {
    
    output[["user"]][["data_import"]] <- tryCatch({
     
      # make sure that only required rows are present
      user_data <- user_data[, c("username", "password", "email")]
      # hash passwords if needed
      if (isTRUE(hash_passwords)) {
        if (isTRUE(verbose)) {
          writeLines(paste0("Hashing passwords from existing data."))
          hash_progress <- utils::txtProgressBar(min = 0, max = nrow(user_data), initial = 0,
                                                 style = 3)
        }
        # iteratively hash passwords
        for (i in seq_along(user_data$password)) {
         user_data$password[i] <- scrypt::hashPassword(user_data$password[i])
         if (isTRUE(verbose)) {
           utils::setTxtProgressBar(hash_progress, value = i)
         }
        }
        if (isTRUE(verbose)) close(hash_progress)
      }
      # add create_time and update_time to the data
      SQL_time <- db_timestamp()
      user_data$create_time <- SQL_time
      user_data$update_time <- SQL_time
      
      # append the whole table
      DBI::dbAppendTable(conn,
                         name = user_name,
                         value = user_data)
      
    },
    warning = function(w) w,
    error = function(e) e)
    
  }
  return(output)
}

#' Create RegLog-valid database tables with googlesheets4
#' 
#' @param user_name Name of the sheet for storing user credentials. Defaults to
#' 'user'. Mandatory spreadsheet.
#' @param reset_code_name Name of the sheet for storing generated password reset
#' codes. Defaults to 'reset_code'. Mandatory table.
#' @param use_log Should the sheet for keeping RegLogServer logs be 
#' also created? Defaults to FALSE
#' @param log_name Name of the sheet for storing logs from RegLogServer object.
#' Used only if `use_log = TRUE`. Defaults to `logs`
#' @param user_data If you wish to import existing user database, you can input
#' data.frame with that table in this argument. It should contain columns:
#' username, password, email. Defaults to NULL.
#' @param hash_passwords If you are importing table of users upon tables creation,
#' you can also specify if the password should be hashed using `scrypt::hashPassword`.
#' Defaults to `FALSE`. If you have unhashed passwords in imported table, set
#' this option to `TRUE`.
#' @param gsheet_ss ID of the googlesheet that you want to append created tables
#' to. Defaults to `NULL`, which means creating new googlesheet.
#' @param gsheet_name If `gsheet_ss = NULL` and new googlesheet will be generated,
#' you can choose choose its name. If left at default `NULL`, name will be
#' generated randomly.
#' @param verbose Boolean specific if the actions made by function should be
#' printed back to the console. Defaults to `TRUE`. Don't affect `googlesheets4`
#' generated messages. To silence them, use `options(googlesheets4_quiet = TRUE)`
#' in the script before.
#' 
#' @details 
#' 
#' Created spreadsheets will have following structure:
#' 
#' - user (default name)
#'   - username: character
#'   - password: character
#'   - email: character
#'   - create_time: character
#'   - update_time: character
#' - reset_code (default name)
#'   - user_id: numeric
#'   - reset_code: character
#'   - used: numeric
#'   - create_time: character
#'   - update_time: character
#' - logs (default name, optional)
#'   - time: character
#'   - session: character
#'   - direction: character
#'   - type: character
#'   - note: character
#' 
#' @return ID of the created googlesheet
#' @example examples/gsheet_tables_create.R
#' @export
#' @family RegLog databases

gsheet_tables_create <- function(
  user_name = "user",
  reset_code_name = "reset_code",
  use_log = FALSE,
  log_name = "logs",
  user_data = NULL,
  hash_passwords = FALSE,
  gsheet_ss = NULL,
  gsheet_name = NULL,
  verbose = TRUE
){
  # if user data is provided, check its validity
  if (!is.null(user_data)) {
    check_user_data(user_data)
  }
  
  # parse tables to write
  tables <- list()
  
  # table with user data
  if (!is.null(user_data)) {
    if (isTRUE(hash_passwords)) {
      if (isTRUE(verbose)) {
        writeLines(paste0("Hashing passwords from existing data."))
        hash_progress <- utils::txtProgressBar(min = 0, max = nrow(user_data), initial = 0,
                                               style = 3)
      }
      # iteratively hash passwords
      for (i in seq_along(user_data$password)) {
        user_data$password[i] <- scrypt::hashPassword(user_data$password[i])
        if (isTRUE(verbose)) {
          utils::setTxtProgressBar(hash_progress, value = i)
        }
      }
      if (isTRUE(verbose)) close(hash_progress)
    }
    db_time <- db_timestamp()
    user_data$create_time <- db_time
    user_data$update_time <- db_time
  } else {
    # create skeleton for data.frame
    user_data <- data.frame(
      username = as.character(NA),
      password = as.character(NA),
      email = as.character(NA),
      create_time = as.character(NA),
      update_time = as.character(NA)
    )[-1, ]
  }
  # append prepared data to the tables
  tables[[user_name]] <- user_data
  
  # table with reset codes
  tables[[reset_code_name]] <- data.frame(
    user_id = as.numeric(NA),
    reset_code = as.character(NA),
    used = as.numeric(NA),
    create_time = as.character(NA),
    update_time = as.character(NA)
  )[-1, ]

  # table for logs if chosen
  if (isTRUE(use_log)) {
    tables[[log_name]] <- data.frame(
      time = as.character(NA),
      session = as.character(NA),
      direction = as.character(NA),
      type = as.character(NA),
      note = as.character(NA)
    )[-1, ]
  }
  
  # if gsheet_ss is not provided, create new spreadsheet
  
  if (is.null(gsheet_ss)) {
    output <- googlesheets4::gs4_create(
      name = if (is.null(gsheet_name)) googlesheets4::gs4_random() else gsheet_name,
      sheets = tables
    )
  } else {
    for (i in seq_along(tables)) {
      output <- googlesheets4::write_sheet(
        data = tables[[i]],
        ss = gsheet_ss,
        sheet = names(tables)[i]
      )
    }
  }
  
  return(output)
}

