#' Emayili email sending handler
#' 
#' @description Default handler function parsing and sending email.
#' Used within object of `RegLogEmayiliConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - email
#' - app_name
#' - app_address
#' - reset_code (optional for reset code mails)
#' 
#' It can also contain *mail_subject* and *mail_body* if you want to send custom
#' `RegLogEmayiliConnector` message.
#' @family mail handler functions
#' @keywords internal

emayili_mail_handler <- function(self, private, message) {
  
  # search message for the subject
  if (!is.null(message$data$mail_subject)) {
    mail_subject <- message$data$mail_subject 
  } else {
    # if none get subject from `self$mails` of mailConnector
    mail_subject <- self$mails[[message$type]][["subject"]]
  }
  
  # interpolate subject with elements found
  mail_subject <- string_interpolate(
    x = mail_subject,
    to_replace = list(
      username = message$data$username,
      email = message$data$email,
      app_name = message$data$app_name,
      app_address = message$data$app_address,
      reset_code = message$data$reset_code
    ))

  # search message for the body
  if (!is.null(message$data$mail_body)) {
    mail_body <- message$data$mail_body
  } else {
    # if none, get the body from `self$mails` of mailConnector
    mail_body <- self$mails[[message$type]][["body"]]
  }

  # interpolate body with elements found
  mail_body <- string_interpolate(
    x = mail_body,
    to_replace = list(
      username = message$data$username,
      email = message$data$email,
      app_name = message$data$app_name,
      app_address = message$data$app_address,
      reset_code = message$data$reset_code
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

#' Gmailr send email handler
#' 
#' @description Default handler function parsing and sending register confirmation 
#' email to newly registered user of the package. Used within object of 
#' `RegLogGmailrConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - email
#' - app_name
#' - app_address
#' - reset_code (optional for reset code mails)
#' 
#' @family mail handler functions
#' @keywords internal

gmailr_mail_handler <- function(self, private, message) {
  
  # search message for the subject
  if (!is.null(message$data$mail_subject)) {
    mail_subject <- message$data$mail_subject 
  } else {
    # if none get subject from `self$mails` of mailConnector
    mail_subject <- self$mails[[message$type]][["subject"]]
  }
  
  # interpolate subject with elements found
  mail_subject <- string_interpolate(
    x = mail_subject,
    to_replace = list(
      username = message$data$username,
      email = message$data$email,
      app_name = message$data$app_name,
      app_address = message$data$app_address,
      reset_code = message$data$reset_code
    ))
  
  # search message for the body
  if (!is.null(message$data$mail_body)) {
    mail_body <- message$data$mail_body
  } else {
    # if none, get the body from `self$mails` of mailConnector
    mail_body <- self$mails[[message$type]][["body"]]
  }
  
  # interpolate body with elements found
  mail_body <- string_interpolate(
    x = mail_body,
    to_replace = list(
      username = message$data$username,
      email = message$data$email,
      app_name = message$data$app_name,
      app_address = message$data$app_address,
      reset_code = message$data$reset_code
    ))
  
  # parse email using gmailr function
  mail <- gmailr::gm_mime() |>
    gmailr::gm_from(private$from) |>
    gmailr::gm_to(message$data$email) |>
    gmailr::gm_subject(message$data$mail_subject) |>
    gmailr::gm_html_body(body = message$data$mail_body)
  
  # send message using gmailr
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