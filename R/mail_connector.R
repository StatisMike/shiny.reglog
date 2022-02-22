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
    initialize = function(
      from,
      smtp,
      lang = "en",
      custom_txts = NULL,
      custom_handlers = NULL
    ) {
      
      # append default handlers
      self$handlers[["register_mail"]] <- emayili_register_handler
      self$handlers[["reset_pass_mail"]] <- emayili_resetPass_handler
      
      # append all custom handlers
      super$initialize(custom_handlers = custom_handlers)
      
      # save smtp server for sending
      private$smtp <- smtp
      private$from <- from
      
      private$custom_txts <- custom_txts
      private$lang <- lang
      
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