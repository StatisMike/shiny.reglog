#' Emayili register confirmation email handler
#' 
#' @description Default handler function parsing and sending email confirming registration.
#' Used within object of `RegLogEmayiliConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - email
#' - app_name
#' - app_address
#' 
#' It can also contain *mail_subject* and *mail_body* if you want to send custom
#' `RegLogEmayiliConnector` message.
#' @family mail handler functions

emayili_register_handler <- function(self, private, message) {
  
  # search message for the subject
  if (!is.null(message$data$mail_subject)) {
    mail_subject <- message$data$mail_subject 
  } else {
    # if none, parse subject from reglog_txt
    mail_subject <- paste("?app_name?",
                          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_h")
    )
  }
  
  # interpolate subject with elements found
  mail_subject <- string_interpolate(
    x = mail_subject,
    to_replace = list(
      username = message$data$username,
      email = message$data$email,
      app_name = message$data$app_name,
      app_address = message$data$app_address
    ))

  # search message for the body
  if (!is.null(message$data$mail_body)) {
    mail_body <- message$data$mail_body
  } else {
    # if none, parse the body from default
    mail_body <- 
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
  }

  # interpolate body with elements found
  mail_body <- string_interpolate(
    x = mail_body,
    to_replace = list(
      username = message$data$username,
      email = message$data$email,
      app_name = message$data$app_name,
      app_address = message$data$app_address
    ))
  
  # parse the email
  mail <- emayili::envelope() |>
    emayili::from(private$from) |>
    emayili::to(message$data$email) |>
    emayili::subject(mail_subject) |>
    emayili::html(content = mail_body)
  
  # and send it!
  message_to_send <- tryCatch({
    private$smtp(mail)
    
    RegLogConnectorMessage(
      message$type,
      success = TRUE,
      logcontent = paste(message$data$username, message$data$email, sep = "/")
    )
    
    }, error = function(e) {
      
      # if error, parse the error message accordingly
      RegLogConnectorMessage(
        message$type,
        success = FALSE,
        logcontent = paste0(message$data$username, "/", message$data$email, "_", e)
      )
    }
  )
  
  # send the RegLogConnectorMessage
  return(message_to_send)
  
}

#' Emayili password reset email handler
#' 
#' @description Default handler function parsing and sending email confirming registration.
#' Used within object of `RegLogEmayiliConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - email
#' - reset_code
#' - app_name
#' - app_address
#' 
#' It can also contain *mail_subject* and *mail_body* if you want to send custom
#' `RegLogEmayiliConnector` message.
#' @family mail handler functions

emayili_resetPass_handler <- function(self, private, message) {
  
  # search message for the subject
  if (!is.null(message$data$mail_subject)) {
    mail_subject <- message$data$mail_subject 
  } else {
    # if none, parse subject from reglog_txt
    mail_subject <- paste("?app_name?",
                          reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mail_h")
    )
  }
  
  # interpolate subject with elements found
  mail_subject <- string_interpolate(
    x = mail_subject,
    to_replace = list(
      username = message$data$username,
      email = message$data$email,
      app_name = message$data$app_name,
      app_address = message$data$app_address
    ))
  
  # search message for the body
  if (!is.null(message$data$mail_body)) {
    mail_body <- message$data$mail_body
  } else {
    # if none, parse the body from default
    mail_body <- 
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
  }
  
  # interpolate body with elements found
  mail_body <- string_interpolate(
    x = mail_body,
    to_replace = list(
      username = message$data$username,
      email = message$data$email,
      app_name = message$data$app_name,
      app_address = message$data$app_address
    ))
  
  # parse the email
  mail <- emayili::envelope() |>
    emayili::from(private$from) |>
    emayili::to(message$data$email) |>
    emayili::subject(message$data$mail_subject) |>
    emayili::html(content = message$data$mail_body)
  
  # and send it!
  message_to_send <- tryCatch({
    private$smtp(mail)
    
    RegLogConnectorMessage(
      message$type,
      success = TRUE,
      logcontent = paste(message$username, message$mail, sep = "/")
    )
    
  }, error = function(e) {
    
    # if error, parse the error message accordingly
    RegLogConnectorMessage(
      message$type,
      success = FALSE,
      logcontent = paste0(message$username, "/", message$mail, "_", e)
    )
  }
  )
  
  # send the RegLogConnectorMessage
  return(message_to_send)
  
}

#' Gmailr send email handler
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
#' - mail_subject
#' - mail_body
#' @family mail handler functions

gmailr_send_handler <- function(self, private, message) {
  
  mail <- gmailr::gm_mime() |>
    gmailr::gm_from(private$from) |>
    gmailr::gm_to(message$data$email) |>
    gmailr::gm_subject(message$data$mail_subject) |>
    gmailr::gm_html_body(body = message$data$mail_body)
  
  message_to_send <- tryCatch({
    gmailr::gm_send_message(mail)
    
    RegLogConnectorMessage(
      message$type,
      success = TRUE,
      logcontent = paste(message$username, message$mail, sep = "/")
    )
    
  }, error = function(e) {
    
    RegLogConnectorMessage(
      message$type,
      success = FALSE,
      logcontent = paste0(message$username, "/", message$mail, "_", e)
    )
  }
  )
  
  return(message_to_send)
  
}