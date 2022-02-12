#' @docType class
#'
#'
#'
#'
#' @import R6

RegLogServer <- R6::R6Class(
  "RegLogServer",
  
  public = list(
    #' @field is_logged logical indicating if the user is logged in
    is_logged = NULL,
    #' @field user_id character specifying the logged user identification name.
    #' If the user is not logged in, it will consist of timestamp prefixed with
    #' 'Anon'
    user_id = NULL,
    #' @field user_mail character containing the logged user mail. When not
    #' logged in, it is empty character string of `nchar()` value of 0: `''`
    user_mail = NULL,
    #' @field login_state_change character containing string describing last
    #' of login system state
    #' @details 
    #' - 'UserNotFound' if the user_id provided wasn't found in database
    #' - 'WrongPass' if the password provided didn't match password for this
    #' user in the database
    #' - 'Success' if the user have been logged succesfully
    login_state_change = NULL,
    #' @field register_state_change character containing string describing
    #' last state of user registration
    #' @details 
    #' 
    register_state_change = NULL,
    #' @field reset_state_change character containing string describing last
    #' state of password resetting
    #' @details 
    #' 
    reset_state_change = NULL,
    #' @field module_id character storing ID for reglog_system module
    module_id = NULL,
    
    #' @description Initialize 'reglog_server' module
    #' 
    #' 
    
    
    initialize = function(
      id = "login_system",
      db_method,
      mail_method,
      appname,
      appaddress,
      lang = "en",
      gsheet_file,
      sqlite_db,
      gmailr_user,
      emayili_user,
      emayili_password,
      emayili_host,
      emayili_port,
      custom_txts = NULL,
      use_login_modals = list(UserNotFound = T,
                              WrongPass = T,
                              Success = T)
    ) {
      
      #### checking for packages for handling databases
      
      if(db_method == "gsheet"){
        
        # packages checks
        if(length(find.package("googlesheets4", quiet = T)) == 0){
          stop("To use this method for database storage, please install 'googlesheets4' package: install.packages('googlesheets4')")
        }
        
      } else if (db_method == "sqlite") {
        if(length(find.package("RSQLite", quiet = T)) + length(find.package("DBI", quiet = T)) != 2) {
          stop("To use this method for database storage, please install 'DBI' and 'RSQLite' packages: install.packages('DBI', 'RSQLite')")
        }
      } else {stop("Valid methods for databases are 'sqlite' or 'gsheet'")}
      
      #### checking for mail sending method ####
      
      if(mail_method == "emayili"){
        if(length(find.package("emayili", quiet = T)) == 0){
          stop("To use this email method, please install 'emayili' package: install.packages('emayili')")
        }
        
      } else if(mail_method == "gmailr"){
        if(length(find.package("gmailr", quiet = T)) == 0){
          stop("To use this email method, please install 'gmailr' package: install.packages('gmailr')")
        }
        
      } else{stop("Valid mailing methods are 'gmailr' or 'emayili'")}
      
    }
    
  ),
  
  private = list(
    # objects to use for database of users
    SQL_conn = NULL,
    gsheet_id = NULL,
    gsheet_sheetname = NULL,
    # objects to use for email sending
    gmailr_user = NULL,
    emayili_user = NULL,
    emayili_password = NULL,
    emayili_host = NULL,
    emayili_port = NULL,
    # additional configuration
    lang = NULL,
    use_login_modals = NULL,
    custom_txts = NULL,
    appname = NULL,
    appaddress = NULL
  )
  
)