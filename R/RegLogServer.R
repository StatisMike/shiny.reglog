#' @docType class
#'
#' @title Login and registration moduleServer
#' @description RegLogServer is an R6 class to use for handling the whole
#' backend of login and registration component of your shinyApp.
#'
#' @import R6
#' @export

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
    #' logged in, it is empty character string of `nchar()` with `length` of 0: `''`
    user_mail = NULL,
    #' @field message reactiveVal containing most recent RegLogConnectorMessage
    #' describing the latest change in the state of the system.
    message = NULL,
    #' @field module_id character storing ID for reglog_system module
    module_id = NULL,
    #' @field dbConnector `RegLogConnector` object used for communication with the
    #' database.
    dbConnector = NULL,
    #' @field mailConnector `RegLogConnector` object used for sending emails.
    mailConnector = NULL,
    #' @field log list containing all messages send and received
    log = list(),
    #' @field tagList_login reactiveVal holding the tagList of whole login UI
    tagList_login = NULL,
    #' @field tagList_resetPass reactiveVal holding the tagList of whole resetPass UI
    tagList_resetPass = NULL,
    #' @field tagList_credsEdit reactiveVal holding the tagList of whole credentioals
    #' edit UI
    tagList_credsEdit = NULL,
    #' @field tagList_register reactiveVal holding the tagList of whole register UI
    tagList_register = NULL, 
    
    #' @description Initialize 'ReglogServer' moduleServer
    #' 
    #' @param dbConnector object of class `RegLogConnector` handling the reads 
    #' from and writes to database.
    #' Two available in the package are `RegLogDBIConnector` and `RegLogGsheetsConnector`.
    #' See their documentation for more information about usage and creation of
    #' custom dbConnectors.
    #' @param mailConnector object of class `RegLogConnector` handling the email
    #' sending to the user for register confirmation and password reset.
    #' Two available in the package are `RegLogEmayiliConnector` and 
    #' `RegLogGmailrConnector`. See their documentation for more information
    #' about usage and creation of custom mailConnectors.
    #' @param app_name Name of the app to refer during correspondence to users.
    #' Defaults to the name of working directory.
    #' @param app_address URL to refer to during correspondence to users. If left
    #' at NULL, the URL will be parsed from `session$clientData`.
    #' @param lang character specyfiyng which language to use for all texts
    #' generated in the UI. Defaults to 'en' for English. Currently 'pl' for
    #' Polish is also supported.
    #' @param custom_txts named list containing character strings with custom
    #' messages. Defaults to NULL, so all built-in strings will be used.
    #' @param use_modals either logical indicating if all (`TRUE`) or none (`FALSE`)
    #' modalDialogs should be shown or character vector indicating which modals
    #' should be shown. For more information see details.
    #' @param module_id Character declaring the id of the module. Defaults to 'login_system'.
    #' Recommended to keep it that way, unless it would cause any namespace issues.
    
    initialize = function(
      dbConnector,
      mailConnector,
      app_name = basename(getwd()),
      app_address = NULL,
      lang = "en",
      custom_txts = NULL,
      use_modals = TRUE,
      module_id = "login_system"
    ) {
      
      # arguments check ####
      # RegLogConnectors
      if (!all(sapply(c(dbConnector, mailConnector), \(x) 'RegLogConnector' %in% class(x)))) {
        stop("Objects provided to 'dbConnector' and 'mailConnector' arguments should be of class 'RegLogConnector'.")
      }
      # app_address
      if (!is.null(app_address) && !is.character(app_address)) {
        stop("'app_address' should be either NULL or character")
      }
      # app_name
      if (!is.character(app_name) || length(app_name) > 1) {
        stop("'app_name' should be a single character string")
      }
      # lang
      if (!lang %in% reglog_texts$.languages_registered) {
        stop(paste("'lang' should be one of:", paste(reglog_texts$.languages_registered, collapse = ", ")))
      }
      # custom_txts
      if (!is.null(custom_txts)) {
        if (!"list" %in% class(custom_txts) || is.null(names(custom_txts)) ||
            sum(sapply(names(custom_txts), \(x) nchar(x) == 0)) > 0) {
          stop("Object provided to 'custom_txts' argument should be a named list")
        } else { # get custom txts into named list

        }
      }
      
      private$use_modals <- use_modals
      
      # save arguments into object ####
      self$module_id <- module_id
      self$dbConnector <- dbConnector
      self$mailConnector <- mailConnector
      private$custom_txts <- custom_txts
      private$app_name <- app_name
      private$lang <- lang
      if (!is.null(app_address)) {
        private$app_address <- app_address
      }
      
      # launch the module
      private$launch_module()
    },
    
    #' @description Method logging out logged user
    logout = function() {
      
      if (isTRUE(self$is_logged())) {
        
        message_to_send <- RegLogConnectorMessage(
          "logout",
          logcontent = paste(self$user_id(), "logged out")
        )
        private$listener(message_to_send)
      }
    },
    
    #' @description Method to receive all saved logs from the object in the form
    #' of single data.frame
    #' @return data.frame
    
    get_logs = function() {
      
      as.data.frame(data.table::rbindlist(self$log))
      
    }
    
  ),
  
  private = list(
    # simple private objects ####
    use_modals = NULL,
    lang = NULL,
    custom_txts = NULL,
    app_name = NULL,
    app_address = NULL,
    listener = NULL,
    app_address_reactVal = NULL,
    
    # private functions ####
    
    launch_module = function() {
      RegLogServer_frontend(self = self, private = private)
      RegLogServer_listener(self = self, private = private)
      RegLogServer_backend(self = self, private = private)
    }
  )
)