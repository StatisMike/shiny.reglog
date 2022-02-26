#' @docType class
#' 
#' @title RegLogConnector for email sending via `emayili` package
#' @description With the use of this object, RegLogServer can send emails
#' confirming the registration and containing code for password reset procedure.
#'
#' @import R6
#' @export


RegLogEmayiliConnector <- R6::R6Class(
  "RegLogEmayiliConnector",
  inherit = RegLogConnector,
  
  public = list(
    
    #' @field mails List containing default mail templates to use by default
    #' mail handlers for register and password reset
    #' @details default mails are used by `register_mail` and `reset_pass_mail`
    #' handlers. To change the mail used by these handlers you can pass character
    #' strings to the `custom_mail` argument during initialization or append them
    #' directly into this list.
    #' 
    #' They are stored (and should be passed accordingly) in a list of structure:
    #' 
    #' - register_mail
    #'    - subject
    #'    - body
    #' - reset_pass_mail
    #'    - subject
    #'    - body

    mails = list(),
  
    #' @description Initialization of the object. Creates smtp server for email
    #' sending.
    #' @param from Character containing content in `from` of the email.
    #' @param smtp Object created by `emayili::server` or all its similiar
    #' functions.
    #' @param lang character specyfiyng which language to use for all texts
    #' generated in the UI. Defaults to 'en' for English. Currently 'pl' for
    #' Polish is also supported.
    #' @param custom_txts named list containing character strings with custom
    #' messages. Defaults to NULL, so all built-in strings will be used.
    #' @param custom_handlers named list of custom handler functions. Custom handler
    #' should take arguments: `self` and `private` - relating to the R6 object
    #' and `message` of class `RegLogConnectorMessage`. It should return
    #' return `RegLogConnectorMessage` object.
    #' @param custom_mails named list containing character strings of the same
    #' structure as elements in the `mails` field. Not all elements need to be
    #' present.

    initialize = function(
      from,
      smtp,
      lang = "en",
      custom_txts = NULL,
      custom_handlers = NULL,
      custom_mails = NULL
    ) {
      
      # language
      private$lang <- lang
      private$custom_txts <- custom_txts
      
      # append default handlers
      self$handlers[["register_mail"]] <- emayili_mail_handler
      self$handlers[["reset_pass_mail"]] <- emayili_mail_handler
      
      # append default mails
      self$mails[["register_mail"]][["body"]] <-
        paste0(
          "<p>",
          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_1"),
          "</p><p>",
          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_2"),
          "?username?",
          "</p><p>",
          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_3"),
          "?app_address?",
          "</p><hr>",
          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "mail_automatic"))
      self$mails[["register_mail"]][["subject"]] <- 
        paste("?app_name?",
              reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_h"))
      
      # append all custom handlers
      super$initialize(custom_handlers = custom_handlers)
      
      # append all custom mails
      handle_custom_mails(self = self, custom_mails = custom_mails)
      
      # save mailing details for sending
      private$smtp <- smtp
      private$from <- from
      
      # assign the unique ID for the module
      self$module_id <- uuid::UUIDgenerate()
      
    }
  ),
  
  private = list(
    smtp = NULL,
    from = NULL,
    custom_txts = NULL,
    lang = NULL
  )
)


#' @docType class
#' 
#' @title RegLogConnector for email sending via `emayili` package
#' @description With the use of this object, RegLogServer can send emails
#' confirming the registration and containing code for password reset procedure.
#'
#' @import R6
#' @export


RegLogGmailrConnector <- R6::R6Class(
  "RegLogGmailrConnector",
  inherit = RegLogConnector,
  
  public = list(
    
    #' @field mails List containing default mail templates to use by default
    #' mail handlers for register and password reset
    #' @details default mails are used by `register_mail` and `reset_pass_mail`
    #' handlers. To change the mail used by these handlers you can pass character
    #' strings to the `custom_mail` argument during initialization or append them
    #' directly into this list.
    #' 
    #' They are stored (and should be passed accordingly) in a list of structure:
    #' 
    #' - register_mail
    #'    - subject
    #'    - body
    #' - reset_pass_mail
    #'    - subject
    #'    - body
    
    mails = list(),
    
    #' @description Initialization of the object. Creates smtp server for email
    #' sending.
    #' @param from Character containing content in `from` of the email.
    #' @param lang character specyfiyng which language to use for all texts
    #' generated in the UI. Defaults to 'en' for English. Currently 'pl' for
    #' Polish is also supported.
    #' @param custom_txts named list containing character strings with custom
    #' messages. Defaults to NULL, so all built-in strings will be used.
    #' @param custom_handlers named list of custom handler functions. Custom handler
    #' should take arguments: `self` and `private` - relating to the R6 object
    #' and `message` of class `RegLogConnectorMessage`. It should return
    #' return `RegLogConnectorMessage` object.
    #' @param custom_mails named list containing character strings of the same
    #' structure as elements in the `mails` field. Not all elements need to be
    #' present.
    
    initialize = function(
      from,
      lang = "en",
      custom_txts = NULL,
      custom_handlers = NULL,
      custom_mails = NULL
    ) {
      
      # language
      private$lang <- lang
      private$custom_txts <- custom_txts
      
      # append default handlers
      self$handlers[["register_mail"]] <- gmailr_mail_handler
      self$handlers[["reset_pass_mail"]] <- gmailr_mail_handler
      
      # append default mails
      self$mails[["register_mail"]][["body"]] <-
        paste0(
          "<p>",
          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_1"),
          "</p><p>",
          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_2"),
          "?username?",
          "</p><p>",
          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_3"),
          "?app_address?",
          "</p><hr>",
          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "mail_automatic"))
      self$mails[["register_mail"]][["subject"]] <- 
        paste("?app_name?",
              reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_h"))
      
      # append all custom handlers
      super$initialize(custom_handlers = custom_handlers)
      
      # append all custom mails
      handle_custom_mails(self = self, custom_mails = custom_mails)
      
      # save mailing details server for sending
      private$from <- from
      
      # assign the unique ID for the module
      self$module_id <- uuid::UUIDgenerate()
      
    }
  ),
  
  private = list(
    from = NULL,
    custom_txts = NULL,
    lang = NULL
  )
)



#' append custom mails to mailConnector object
#' 
#' @noRd

handle_custom_mails <- function(self, custom_mails)
  
  # assign custom mails if any present
  if (!is.null(custom_mails)) {
    ## checks if the custom_mails are correct
    ## custom mails should be a list
    if (class(custom_mails) == "list" &&
        ## all elements of it needs to be named
        all(sapply(names(custom_mails), \(x) nchar(x) > 0)) &&
        ## all elements need to be of class 'list'
        all(sapply(custom_mails, \(x) {
          ("list" %in% class(x)) && 
            ## all elements inside every list need to be named either 'subject' or 'body'
            all(names(x) %in% c("subject", "body"))
        }))
        
    ) {
      
      for (mail_name in names(custom_mails)) {
        for (element_name in names(custom_mails[[mail_name]])) {
          # assign every custom mail in the self$objects
          self$mails[[mail_name]][[element_name]] <-
            custom_mails[[mail_name]][[element_name]]
        }
      }
      
    } else {
      stop("Object passed to the 'custom_mails' should be a named list containing list of character strings
         named 'subject' and/or 'body'.")
    }
  }