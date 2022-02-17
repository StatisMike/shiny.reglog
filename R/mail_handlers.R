#' Emayili register handler
#' 
#' @description Default handler function parsing and sending register confirmation 
#' email to newly registered user of the package. Used within object of 
#' `RegLogEmayiliConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - email
#' @family emayili handler functions


emayili_register_handler <- function(self, private, message) {
  
  mail_subject <- paste(private$app_name,
        reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_h")
  )
  
  mail_body <- 
    paste0(
      "<p>",
      reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_1"),
      "</p><p>",
      reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_2"),
      message$username,
      "</p><p>",
      reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_3"),
      private$app_address,
      "</p><hr>",
      reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "mail_automatic"))
  
  mail <- emayili::envelope() |>
    emayili::from(private$from) |>
    emayili::to(message$email) |>
    emayili::subject(mail_subject) |>
    emayili::html(mail_body)
  
  message_to_send <- tryCatch({
    private$smtp(email)
    
    RegLogConnectorMessage(
      "register_mail",
      success = TRUE,
      logcontent = paste(message$username, message$mail, sep = "/")
    )
    
    }, error = function(e) {
      
      RegLogConnectorMessage(
        "register_mail",
        success = FALSE,
        logcontent = paste0(message$username, "/", message$mail, "_")
      )
    }
  )
  
  return(message_to_send)
  
}