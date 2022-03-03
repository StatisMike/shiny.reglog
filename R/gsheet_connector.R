#' @docType class
#' 
#' @title Connector to googlesheet database
#' @description Object of this class handles all connections for the RegLogServer
#' object to the database. It is created to handle googlesheet database.
#' Provides methods than will be used by RegLogServer to get and send data.
#' 
#' @import R6
#' @export

RegLogGsheetConnector = R6::R6Class(
  "RegLogGsheetConnector",
  inherit = RegLogConnector,
  # private elements ####
  private = list(
    # storage of connection 
    gsheet_ss = NULL,
    # table names
    gsheet_sheetnames = NULL,
    # cached user data
    data_user = NULL,
    # cached reset codea data
    data_reset_code = NULL,
    # method to input log into database
    input_log = function(message, direction, session) {
      
      log_data <- data.frame(
        time = message$time,
        session = session$token,
        direction = direction,
        type = message$type,
        note = message$logcontent)
      
      googlesheets4::sheet_append(
        ss =  gsheet_ss,
        data = log_data,
        sheet = private$gsheet_sheetnames[3]
      )
    },
    # method to get specified sheet of type 'user' or 'reset_code'
    get_sheet = function(sheet, type) {
      switch(type,
        user = {
          private$data_user <- googlesheets4::read_sheet(
            ss = private$gsheet_ss,
            sheet = private$gsheet_sheetnames[1],
            col_types = "c"
          )
        },
        reset_code = {
          private$data_reset_code <- googlesheets4::read_sheet(
            ss = private$gsheet_ss,
            sheet = private$gsheet_sheetnames[2],
            col_types = "icicc"
          )
        }
      )
    }
  ),
  # public elements ####
  public = list(
    
    #' @description Initialization of the object. Creates initial connection
    #' to the database.
    #' 
    #' @param gsheet_ss id of the googlesheet holding database
    #' @param gsheet_sheetnames character vector. Contains names of the sheets in the
    #' googlesheet: first containing user data, second - reset codes information,
    #' third (optional) - logs from the object. For more info check documentation
    #' of `gsheet_database_create`.
    #' @param custom_handlers named list of custom handler functions. Custom handler
    #' should take arguments: `self` and `private` - relating to the R6 object
    #' and `message` of class `RegLogConnectorMessage`. It should return
    #' return `RegLogConnectorMessage` object.
    #' 
    #' @return object of `RegLogDBIConnector` class
    #' 
    
    initialize = function(
      gsheet_ss,
      gsheet_sheetnames = c("user", "reset_code", "logs"),
      custom_handlers = NULL
    ) {
      
      # append default handlers
      self$handlers[["login"]] <- gsheet_login_handler
      self$handlers[["register"]] <- gsheet_register_handler
      self$handlers[["credsEdit"]] <- gsheet_creds_edit_handler
      self$handlers[["resetPass_generate"]] <- gsheet_resetPass_generation_handler
      self$handlers[["resetPass_confirm"]] <- gsheet_resetPass_confirmation_handler
      
      super$initialize(custom_handlers = custom_handlers)
      # store the arguments internally
      private$db_tables <- table_names
      # assign the unique ID for the module
      self$module_id <- uuid::UUIDgenerate()
    }
  )
)