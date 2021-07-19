#' Function to create new 'SQLite' database
#' 
#' @param output_file path to new 'SQLite' database. After creation you need to provide it to \code{login_server()}
#' @param credentials you can pass credentials data to create already populated tables. Provide list containing \code{user_db} and \code{reset_db}
#' @importFrom DBI dbConnect 
#' @importFrom RSQLite SQLite dbExecute dbDisconnect
#' 
#' @export
#' 
#' @example examples/create_sqlite_db.R
#' 

create_sqlite_db <- function(output_file, credentials = NULL){
  
  conn <- DBI::dbConnect(RSQLite::SQLite(), output_file)
  
  on.exit(DBI::dbDisconnect(conn))
  
  if(!is.null(credentials)){
    
    if(!is.list(credentials) || !all(c("user_db", "reset_db") %in% names(credentials))){
      stop("Object referenced in `credentials` argument should be a list containing data.frames named: `user_db` and `reset_db`")
    }
    if(!all(c("timestamp", "user_id", "user_mail", "user_pass") %in% names(credentials$user_db))){
      stop("Table named `user_db` must contain columns: `timestamp`, `user_id`, `user_mail` and `user_pass`")
    }
    if(!all(c("timestamp", "user_id", "user_mail", "user_pass") %in% names(credentials$user_db))){
      stop("Table named `reset_db` must contain columns: `timestamp`, `user_id` and `reset_code`")
    }
    
    prev_user_db <- credentials$user_db
    prev_user_db <- dplyr::arrange(prev_user_db, dplyr::desc(timestamp))
    prev_user_db <- dplyr::group_by(prev_user_db, user_id)
    prev_user_db <- dplyr::slice_head(prev_user_db)
    prev_user_db <- dplyr::ungroup(prev_user_db)
    
    prev_reset_db <- credentials$reset_db
    prev_reset_db <- dplyr::arrange(prev_reset_db, dplyr::desc(timestamp))
    prev_reset_db <- dplyr::group_by(prev_reset_db, user_id)
    prev_reset_db <- dplyr::slice_head(prev_reset_db)
    prev_reset_db <- dplyr::ungroup(prev_reset_db)
  }

  # create user_db table
  
  RSQLite::dbExecute(conn,
                   "CREATE TABLE user_db (
                   timestamp INTEGER,
                   user_id TEXT PRIMARY KEY,
                   user_mail TEXT,
                   user_pass TEXT
                   );")
  
  if(exists("prev_user_db", inherits = FALSE)){
    
    for(n in 1:nrow(prev_user_db)){
    
    temp_row <- prev_user_db[n,]
    
    query <- RSQLite::dbSendQuery(conn,
                         "INSERT INTO user_db (timestamp, user_id, user_mail, user_pass) VALUES (:timestamp, :user_id, :user_mail, :user_pass)
                         ON CONFLICT (user_id) DO UPDATE SET user_pass = :user_pass;",
                         temp_row)
    
    RSQLite::dbClearResult(query)
    }
    
  }
  
  # create reset_db table
  RSQLite::dbExecute(conn,
                     "CREATE TABLE reset_db (
                   timestamp INTEGER,
                   user_id TEXT PRIMARY KEY,
                   reset_code TEXT);")
  
  if(exists("prev_reset_db", inherits = FALSE)){
    
    for(n in 1:nrow(prev_reset_db)){
      
      temp_row <- prev_reset_db[n,]
      
      query <- RSQLite::dbSendQuery(conn,
                           "INSERT INTO reset_db (timestamp, user_id, reset_code) VALUES (:timestamp, :user_id, :reset_code)
                            ON CONFLICT (user_id) DO UPDATE SET reset_code = :reset_code;",
                           temp_row)
      
      RSQLite::dbClearResult(query)
    }
    
  }
  
}


#' Function to create new empty 'googlesheet' database
#' 
#' @param name specify name for 'googlesheet' file. Defaults to random name.
#' @return id of the 'googlesheet' file. After creation you need to provide it to \code{login_server()}.
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

#' Function to read SQLite shiny.reglog database
#' 
#' @param sqlite_db path to your 'SQLite' database
#' 
#' @return list containing \code{user_db} and \code{reset_db} dataframes
#' 
#' @importFrom DBI dbConnect 
#' @importFrom DBI dbDisconnect
#' @importFrom RSQLite SQLite
#' @importFrom dplyr collect
#' @importFrom dplyr mutate
#' 
#' @export
#' @seealso create_sqlite_db
#' 

sqlite_get_db <- function(sqlite_db){
  
  sq_db <- DBI::dbConnect(RSQLite::SQLite(), dbname = sqlite_db)
  
  user_db <- dplyr::collect(dplyr::tbl(sq_db, "user_db"))
  user_db <- dplyr::mutate(user_db, timestamp = as.POSIXct(as.numeric(timestamp), origin = "1970-01-01"))
  
  reset_db <- dplyr::collect(dplyr::tbl(sq_db, "reset_db")) 
  reset_db <- dplyr::mutate(reset_db, timestamp = as.POSIXct(as.numeric(timestamp), origin = "1970-01-01"))
  
  DBI::dbDisconnect(sq_db)
  
  return(
    list(user_db = user_db,
         reset_db = reset_db)
  )
}

#' Function to read googlesheets shiny.reglog database
#' 
#' @param gsheet_db ID of your 'googlesheets' database
#' 
#' @return list containing \code{user_db} and \code{reset_db} dataframes
#' 
#' @importFrom googlesheets4 read_sheet
#' @importFrom dplyr arrange group_by slice_head ungroup
#' 
#' @export
#' @seealso create_sqlite_db
#' 

gsheet_get_db <- function(gsheet_db){
  
  user_db <- googlesheets4::read_sheet(ss = gsheet_db, sheet = "user_db")
  user_db <- dplyr::arrange(user_db, dplyr::desc(timestamp))
  user_db <- dplyr::group_by(user_db, user_id)
  user_db <- dplyr::slice_head(user_db)
  user_db <- dplyr::ungroup(user_db)
  
  reset_db <- googlesheets4::read_sheet(ss = gsheet_db, sheet = "reset_db")
  reset_db <- dplyr::arrange(reset_db, dplyr::desc(timestamp))
  reset_db <- dplyr::group_by(reset_db, user_id)
  reset_db <- dplyr::slice_head(reset_db)
  reset_db <- dplyr::ungroup(reset_db)
  
  return(
    list(user_db = user_db,
         reset_db = reset_db)
  )
}