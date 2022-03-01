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
  if (!all(c("username", "password", "email") %in% names(user_date))) {
    stop(call. = F, "Data.frame containing user data needs to contain columns: 'username', 'password' and 'email'.")
  }
  if (sum(is.na(user_data$username), is.na(user_data$password), is.na(user_data$email)) > 0) {
    stop(call. = F, "Provided user data can't contain any NA values.")
  }
}


#' Create RegLog-valid database tables with DBI
#' 
#' @param conn DBI connection object
#' @param user_name Name of table for storing user credentials. Defaults to
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
#' 
#' @details Currently, the function is tested and working correctly for
#' SQLite and MySQL databases. If you want to use another DBI-supported
#' database, you need to create tables in other ways. 
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
#' @export
#' @family RegLog databases

RegLog_DBI_database_create <- function(
  conn,
  user_name = "user",
  reset_code_name = "reset_code",
  use_log = FALSE,
  log_name = "logs",
  user_data = NULL,
  hash_passwords = FALSE
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
        "create_time" = "DATETIME NOT NULL",
        "update_time" = "DATETIME NOT NULL")
    ),
    error = function(e) e,
    warning = function(w) w
  )
  
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
        "used" = "TINYINT NOT NULL",
        "create_time" = "DATETIME NOT NULL",
        "update_time" = "DATETIME NOT NULL")
      ),
    error = function(e) e,
    warning = function(w) w
  )
  
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
          "time" = "DATETIME NOT NULL",
          "session" = "VARCHAR(255) NOT NULL",
          "direction" = "VARCHAR(255) NOT NULL",
          "type" = "VARCHAR(255) NOT NULL",
          "note" = "VARCHAR(255)")),
      error = function(e) e,
      warning = function(w) w
    )
  }
  
  # optionally: insert user data
  if (!is.null(user_data)) {
    
    output[["user"]][["data_import"]] <- tryCatch({
      # use sql template
      sql <- paste("INSERT INTO", user_name, 
                   "(username, password, email, create_time, update_time)",
                   "VALUES (?username, ?password, ?email, ?time, ?time);")
      
      # insert data into table iteratively
      for (i in 1:nrow(user_data)) {
        
        query <- DBI::sqlInterpolate(
          conn, sql, username = user_data$username[i],
          password = if(hash_passwords) scrypt::hashPassword(user_data$password[i]) 
          else user_data$password[i],
          email = user_data$email[i],
          time = db_timestamp()
        )
      }
    },
    warning = function(w) w,
    error = function(e) e)
    
  }
  return(output)
}
