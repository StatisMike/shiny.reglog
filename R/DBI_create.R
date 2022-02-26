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
#'   - used: tinyint, NOT NULL
#'   - create_time: datetime, NOT NULL
#'   - update_time: datetime, NOT NULL
#' - logs (default name, optional)
#'   - id: integer, primary key, auto-increment
#'   - time: numeric, size 15, 5 decimal, NOT NULL
#'   - session: varchar(255), NOT NULL
#'   - direction: varchar(255), NOT NULL
#'   - type: varchar(255), NOT NULL
#'   - note: varchar(255)
#' 
#' @export
#' @family RegLog databases

RegLog_DBI_database_create <- function(
  conn,
  user_name = "user",
  reset_code_name = "reset_code",
  use_log = FALSE,
  log_name = "logs")
  
{
  
  class <- class(conn)[1]
  
  if (!class %in% supported_db_connections) {
    stop(paste("This function "))
  }
  
  output <- list()
  
  # create user table
  
  output[["user"]][["table_name"]] <- user_name
  output[["user"]][["result"]] <- tryCatch(
    DBI::dbCreateTable(
      conn,
      user_name,
      c("id" = if (class == "SQLiteConnection") "INT PRIMARY KEY"
          else if (class == "MySQLConnection") "INT PRIMARY KEY AUTO_INCREMENT",
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
      c("id" = if (class == "SQLiteConnection") "INT PRIMARY KEY"
          else if (class == "MySQLConnection") "INT PRIMARY KEY AUTO_INCREMENT",
        "user_id" = "INT NOT NULL",
        "used" = "TINYINT NOT NULL",
        "create_time" = "DATETIME NOT NULL",
        "update_time" = "DATETIME NOT NULL")
      ),
    error = function(e) e,
    warning = function(w) w
  )
  
  # optionally - create log-storing table
  
  # if (isTRUE(use_log)) {
  #   
  #   output[["log"]][["table_name"]] <- log_name
  #   output[["log"]][["result"]] <- tryCatch(
  #     DBI::dbCreateTable(
  #       conn,
  #       reset_code_name,
  #       c("id" = "INT PRIMARY KEY",
  #         "user_id" = "INT NOT NULL UNIQUE",
  #         "used" = "TINYINT NOT NULL",
  #         "create_time" = "DATETIME NOT NULL",
  #         "update_time" = "DATETIME NOT NULL")
  #     ),
  #     error = function(e) e,
  #     warning = function(w) w
  #   )
  #   
  # }
  
  return(output)
  
}
