#' Function to create new empty sqlite database
#' 
#' @param output_file path to new sqlite database. After creation you need to provide it to \code{login_server()}
#' @importFrom DBI dbConnect 
#' @importFrom RSQLite SQLite dbExecute dbDisconnect
#' 
#' @export
#' 
#' @example examples/create_sqlite_db.R
#' 

create_sqlite_db <- function(output_file){

  conn <- DBI::dbConnect(RSQLite::SQLite(), output_file)
  
  # create user_db table
  RSQLite::dbExecute(conn,
                     "CREATE TABLE user_db (
                   timestamp INTEGER,
                   user_id TEXT PRIMARY KEY,
                   user_mail TEXT,
                   user_pass TEXT
                   );")
  
  # create reset_db table
  RSQLite::dbExecute(conn,
                     "CREATE TABLE reset_db (
                   timestamp INTEGER,
                   user_id TEXT PRIMARY KEY,
                   reset_code TEXT);")
  
  # remember to disconnect after using database!
  RSQLite::dbDisconnect(conn)
  
}


#' Function to create new empty googlesheet database
#' 
#' @param name specify name for googlesheet. Defaults to random name.
#' @return id of the googlesheet. After creation you need to provide it to \code{login_server()}.
#' @import googlesheets4
#' 
#' @export
#' 
#' @example examples/create_gsheet_db.R

create_gsheet_db <- function(name = NULL){
  
  if(is.null(name)){
    name <- googlesheets4::gs4_random()
  }
  
  sheets <- list(
    user_db = data.frame(
      timestamp = Sys.time(),
      user_id = "",
      user_mail = "",
      user_pass = ""
    )[-1,],
    reset_db = data.frame(
      timestamp = Sys.time(),
      user_id = "",
      reset_code = ""
    )[-1,]
  )
  
  id <- googlesheets4::gs4_create(
    name = name,
    sheets = sheets
  )
  
  return(id)
  
}
