.db_filtering <- function(credentials, credentials_pass_hashed){

  user_db <- credentials
  user_db <- dplyr::arrange(user_db, dplyr::desc(timestamp))
  user_db <- dplyr::group_by(user_db, user_id)
  user_db <- dplyr::slice_head(user_db)
  user_db <- dplyr::ungroup(user_db)

  if(credentials_pass_hashed){
    user_db$user_pass <- sapply(user_db$user_pass, scrypt::hashPassword)
  }

  return(user_db)
 
}

#' Function to create new 'SQLite' database
#' 
#' @param output_file path to new 'SQLite' database. After creation you need to provide it to \code{login_server()}
#' @param credentials you can pass credentials data to create already populated tables. Provide data.frame object containing variables: timestamp, user_id, user_mail and user_pass. If there are multiple records with the same user_id, the most recent will be kept only.
#' @param credentials_pass_hashed specify if you put in some credentials data. Are the passwords already hashed with 'scrypt' package? Takes TRUE (if hashed) or FALSE (if not hashed and need hashing)
#' @importFrom DBI dbConnect 
#' @importFrom RSQLite SQLite dbExecute dbDisconnect
#' 
#' @export
#' 
#' @example examples/create_sqlite_db.R
#' 

create_sqlite_db <- function(output_file, credentials = NULL, credentials_pass_hashed){

  conn <- DBI::dbConnect(RSQLite::SQLite(), output_file)

  on.exit(DBI::dbDisconnect(conn))

  if(!is.null(credentials)){

    if (!all(c("timestamp", "user_id", "user_mail", "user_pass") %in% names(credentials))) {
      stop("Table provided in 'credentials' argument must contain columns: `timestamp`, `user_id`, `user_mail` and `user_pass`")
    }
    
    cred_db <- .db_filtering(credentials, credentials_pass_hashed)
      
  }

  # create user_db table
  
  query <- RSQLite::dbSendQuery(
    conn,
    "CREATE TABLE user_db (
     timestamp INTEGER,
     user_id TEXT PRIMARY KEY,
     user_mail TEXT,
     user_pass TEXT
     );")
  
  RSQLite::dbClearResult(query)
  
  if(!is.null(credentials)){

    for(n in 1:nrow(cred_db)){

    temp_row <- cred_db[n,]

    query <- RSQLite::dbSendQuery(
      conn,
      "INSERT INTO user_db (timestamp, user_id, user_mail, user_pass) VALUES (:timestamp, :user_id, :user_mail, :user_pass)
       ON CONFLICT (user_id) DO UPDATE SET user_pass = :user_pass;",
       temp_row)
    
    RSQLite::dbClearResult(query)
    }

  }

  # create reset_db table
  query <- RSQLite::dbSendQuery(conn,
                     "CREATE TABLE reset_db (
                   timestamp INTEGER,
                   user_id TEXT PRIMARY KEY,
                   reset_code TEXT);")
  
  RSQLite::dbClearResult(query)

}


#' Function to create new empty 'googlesheet' database
#' 
#' @param name specify name for 'googlesheet' file. Defaults to random name.
#' @return id of the 'googlesheet' file. After creation you need to provide it to \code{login_server()}.
#' @param credentials you can pass credentials data to create already populated tables. Provide data.frame object containing variables: timestamp, user_id, user_mail and user_pass. If there are multiple records with the same user_id, the most recent will be kept only.
#' @param credentials_pass_hashed mandatory when putting some credentials data. Are the passwords already hashed with 'scrypt' package? Takes TRUE (if hashed) or FALSE (if not hashed and need hashing)
#' @import googlesheets4
#' 
#' @export
#' 
#' @example examples/create_gsheet_db.R

create_gsheet_db <- function(name = NULL, credentials = NULL, credentials_pass_hashed){

  if(!is.null(credentials)){

    if (!all(c("timestamp", "user_id", "user_mail", "user_pass") %in% names(credentials))) {
      stop("Table named `user_db` must contain columns: `timestamp`, `user_id`, `user_mail` and `user_pass`")
    }

  cred_db <- .db_filtering(credentials, credentials_pass_hashed)
    
  }

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

  if(!is.null(credentials)){

    googlesheets4::sheet_append(ss = id,
                                sheet = "user_db",
                                data = cred_db)

  }

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
  
  user_db <- DBI::dbGetQuery(
    sq_db,
    "SELECT * FROM user_db")
  user_db <- dplyr::mutate(user_db, timestamp = as.POSIXct(as.numeric(timestamp), origin = "1970-01-01"))
  
  reset_db <- DBI::dbGetQuery(
    sq_db,
    "SELECT * FROM reset_db")
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
  
  user_db <- googlesheets4::read_sheet(ss = gsheet_db, 
                                       sheet = "user_db",
                                       col_types = "Tccc")
  user_db <- dplyr::arrange(user_db, dplyr::desc(timestamp))
  user_db <- dplyr::group_by(user_db, user_id)
  user_db <- dplyr::slice_head(user_db)
  user_db <- dplyr::ungroup(user_db)
  
  reset_db <- googlesheets4::read_sheet(ss = gsheet_db, 
                                        sheet = "reset_db",
                                        col_types = "Tcc")
  reset_db <- dplyr::arrange(reset_db, dplyr::desc(timestamp))
  reset_db <- dplyr::group_by(reset_db, user_id)
  reset_db <- dplyr::slice_head(reset_db)
  reset_db <- dplyr::ungroup(reset_db)
  
  return(
    list(user_db = user_db,
         reset_db = reset_db)
  )
}
