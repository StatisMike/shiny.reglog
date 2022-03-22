#' googlesheets login handler
#' 
#' @description Default handler function querying database to confirm login 
#' procedure. Used within object of `RegLogGsheetConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - password
#' @family googlesheets handler functions
#' @concept gsheet_handler
#' @keywords internal

gsheet_login_handler <- function(self, private, message) {
  
  check_namespace("googlesheets4")
  
  # download the database into the private
  private$get_sheet("account")
  
  user_data <- private$data_user[private$data_user$username == message$data$username, ]
  
  # check condition and create output message accordingly
  
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happened
    
    RegLogConnectorMessage(
      "login", success = FALSE, username = FALSE, password = FALSE,
      logcontent = paste(message$data$username, "don't exist")
    )
    
  } else {
    # if there is a row present, check password
    
    if (scrypt::verifyPassword(user_data$password, message$data$password)) {
      # if success: user logged in
      
      RegLogConnectorMessage(
        "login", success = TRUE, username = TRUE, password = TRUE,
        user_id = user_data$username,
        user_mail = user_data$email,
        account_id = which(private$data_user$username == user_data$username),
        logcontent = paste(message$data$username, "logged in")
      )
      
    } else {
      # if else: the password didn't match
      
      RegLogConnectorMessage(
        "login", success = FALSE, username = TRUE, password = FALSE,
        logcontent = paste(message$data$username, "bad pass")
      )
    }
  }
}

#' googlesheets register handler
#' 
#' @description Default handler function querying database to confirm registration 
#' validity and input new data. Used within object of `RegLogGsheetConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - password
#' - email
#' @family googlesheets handler functions
#' @concept gsheet_handler
#' @keywords internal

gsheet_register_handler = function(self, private, message) {
  
  check_namespace("googlesheets4")
  
  # download the database into the private
  private$get_sheet("account")
  
  user_data <- private$data_user[private$data_user$username == message$data$username |
                                   private$data_user$email == message$data$email, ]
  
  if (nrow(user_data) > 0) {
    # if query returns data don't register new
    message_to_send <- RegLogConnectorMessage(
      "register", 
      success = FALSE, 
      username = !message$data$username %in% user_data$username,
      email = !message$data$email %in% user_data$email)
    
    if (!message_to_send$data$username && !message_to_send$data$email) {
      message_to_send$logcontent <- paste0(message$data$username, "/", message$data$email, " conflict")
    } else if (!message_to_send$data$username) {
      message_to_send$logcontent <- paste(message$data$username, "conflict")
    } else if (!message_to_send$data$email) {
      message_to_send$logcontent <- paste(message$data$email, "conflict")
    }
    
    return(message_to_send)
    
  } else {
    
    # append data if checks were succsessful
    googlesheets4::sheet_append(
      ss = private$gsheet_ss,
      sheet = private$gsheet_sheetnames[1],
      data = data.frame(
        username = message$data$username, 
        password = scrypt::hashPassword(message$data$password),
        email = message$data$email,
        create_time = db_timestamp(),
        update_time = db_timestamp()
      )
    )
    
    return(
      RegLogConnectorMessage(
        "register", 
        success = TRUE, username = TRUE, email = TRUE,
        user_id = message$data$username,
        user_mail = message$data$email,
        logcontent = paste(message$data$username, message$data$email, sep = "/")
      )
    )
  }
}

#' googlesheets edit to the database handler
#' 
#' @description Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogGsheetConnector` class internally.
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which need to contain within its data:
#' - username
#' - password
#' 
#' It can also contain elements for change:
#' - new_username
#' - new_email
#' - new_password
#' @family googlesheets handler functions
#' @concept gsheet_handler
#' @keywords internal

gsheet_credsEdit_handler <- function(self, private, message) {
  
  check_namespace("googlesheets4")
  
  # download the database into the private
  private$get_sheet("account")

  user_data <- private$data_user[message$data$account_id, ]

  # check password
    
  if (isFALSE(scrypt::verifyPassword(user_data$password, message$data$password))) {
    # if FALSE: don't allow changes
    message_to_send <- RegLogConnectorMessage(
      "credsEdit", success = FALSE, password = FALSE,
      logcontent = paste(user_data$username, "bad pass")
    )
  } else {
    # if TRUE: allow changes
    
    ## Additional checks: if unique values (username, email) that are to be changed
    ## are already present in the database
    matches <- 0
    # check if there is an username existing
    if (!is.null(message$data$new_username)) {
      matches <- matches + message$data$new_username %in% private$data_user$username 
    }
    # check if there is an email existing
    if (!is.null(message$data$new_email)) {
      matches <- matches + message$data$new_email %in% private$data_user$email
    }
    # if something is returned, send fail back
    if (matches > 0) {
      
      message_to_send <- RegLogConnectorMessage(
        "credsEdit", success = FALSE, password = TRUE,
        # if there is a conflict, these returns FALSE
        new_username = !isTRUE(message$data$new_username %in% private$data_user$username),
        new_email = !isTRUE(message$data$new_email %in% private$data_user$email))
      
      message_to_send$logcontent <-
        paste0(user_data$username, " conflict:",
               if (!message_to_send$data$new_username) paste(" username:", message$data$new_username),
               if (!message_to_send$data$new_email) paste(" email:", message$data$new_email), "." )
      
    } else {
      # if nothing is returned, update can be made!
      # generate row that need to be updated
      row_to_update <- data.frame(
        username = if (is.null(message$data$new_username)) private$data_user[message$data$account_id, "username"]
        else message$data$new_username,
        password = if (is.null(message$data$new_password)) private$data_user[message$data$account_id, "password"]
        else scrypt::hashPassword(message$data$new_password),
        email = if (is.null(message$data$new_email)) private$data_user[message$data$account_id, "email"]
        else message$data$new_email,
        create_time = private$data_user[message$data$account_id, "create_time"],
        update_time = db_timestamp()
      )
      # range write
      googlesheets4::range_write(
        ss = private$gsheet_ss,
        sheet = private$gsheet_sheetnames[1],
        range = paste0("A", message$data$account_id +1, ":E", message$data$account_id + 1),
        data = row_to_update,
        col_names = F
      )
      
      message_to_send <- RegLogConnectorMessage(
        "credsEdit", success = TRUE, password = TRUE,
        new_user_id = message$data$new_username,
        new_user_mail = message$data$new_email,
        new_user_pass = if(!is.null(message$data$new_password)) TRUE else NULL)
      
      info_to_log <- 
        c(message_to_send$data$new_user_id,
          message_to_send$data$new_user_mail,
          if (!is.null(message_to_send$new_user_pass)) "pass_change")
      
      message_to_send$logcontent <-
        paste(user_data$username, "updated",
              paste(info_to_log,
                    collapse = "/")
        )
    }
  }
  
  
  return(message_to_send)
}

#' googlesheets resetpass code generation handler
#' 
#' @description Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogGsheetConnector` class internally.
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which need to contain within its data:
#' - username
#' 
#' @family googlesheets handler functions
#' @concept gsheet_handler
#' @keywords internal

gsheet_resetPass_generation_handler <- function(self, private, message) {
  
  check_namespace("googlesheets4")
  
  # download the database into the private
  private$get_sheet("account")
  
  # firstly check login credentials
  user_data <- private$data_user[private$data_user$username == message$data$username, ]
  
  # check condition and create output message accordingly
  
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happened
    
    message_to_send <- RegLogConnectorMessage(
      "resetPass_generate", success = FALSE, 
      logcontent = paste(message$data$username, "don't exist")
    )
    
    # if username exists, generate new resetpass code
  } else {
    
    # get the user id
    user_id <- which(private$data_user$username == message$data$username)
    reset_code <- paste(floor(stats::runif(10, min = 0, max = 9.9)), collapse = "")
    
    data_to_append <- data.frame(
      user_id = user_id,
      reset_code = reset_code,
      user = 0,
      create_time = db_timestamp(),
      update_time = db_timestamp()
    )
    
    googlesheets4::sheet_append(
      ss = private$gsheet_ss,
      sheet = private$gsheet_sheetnames[2],
      data = data_to_append
    )
    
    message_to_send <- RegLogConnectorMessage(
      "resetPass_generate", success = TRUE,  
      user_id = message$data$username,
      user_mail = user_data$email,
      reset_code = reset_code,
      logcontent = paste(message$data$username, "code generated")
    )
  }
  return(message_to_send)
}

#' googlesheets resetpass code confirmation handler
#' 
#' @description Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogGsheetConnector` class internally.
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which need to contain within its data:
#' - username
#' - reset_code
#' - password
#' 
#' @family googlesheets handler functions
#' @concept gsheet_handler
#' @keywords internal

gsheet_resetPass_confirmation_handler <- function(self, private, message) {
  
  check_namespace("googlesheets4")
  
  # download the database into the private
  private$get_sheet("account")
  
  # firstly check login credentials
  user_data <- private$data_user[private$data_user$username == message$data$username, ]
  
  # check condition and create output message accordingly
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happened
    
    message_to_send <- RegLogConnectorMessage(
      "resetPass_confirm", success = FALSE, username = FALSE, code_valid = FALSE,
      logcontent = paste(message$data$username, "don't exist")
    )
    
    # if username exists, check for the resetcode
  } else {
    
    user_id <- which(private$data_user$username == message$data$username)
    private$get_sheet("reset_code")
    
    reset_code_data <- private$data_reset_code[
      private$data_reset_code$user_id == user_id &
        private$data_reset_code$reset_code == message$data$reset_code &
        private$data_reset_code$used == 0,
    ]
    
    not_expired <- 
      (lubridate::as_datetime(reset_code_data$create_time) + lubridate::period(4, "hours")) > Sys.time()
    
    # if not used reset code matches and isn't expired, update the database
    if (nrow(reset_code_data) > 0 && not_expired) {
      
      # update user data
      user_data_update <- data.frame(
        username =user_data$username,
        password = scrypt::hashPassword(message$data$password),
        email = user_data$email,
        create_time = user_data$create_time,
        update_time = db_timestamp()
      )
      
      googlesheets4::range_write(
        ss = private$gsheet_ss,
        sheet = private$gsheet_sheetnames[1],
        range = paste0("A", user_id+1, ":E", user_id+1),
        col_names = F,
        data = user_data_update
      )
      
      # update reset_code
      reset_id <- which(private$data_reset_code$reset_code == message$data$reset_code &
                          private$data_reset_code$user_id == user_id &
                          private$data_reset_code$used == 0)
      
      reset_code_data_update <- data.frame(
        user_id = user_id,
        reset_code = message$data$reset_code,
        used = 1,
        create_time = reset_code_data$create_time,
        update_time = db_timestamp()
      )

      googlesheets4::range_write(
        ss = private$gsheet_ss,
        sheet = private$gsheet_sheetnames[2],
        range = paste0("A", reset_id+1, ":E", reset_id+1),
        data = reset_code_data_update,
        col_names = F
      )
      
      message_to_send <- RegLogConnectorMessage(
        "resetPass_confirm", success = TRUE, username = TRUE, code_valid = TRUE,
        logcontent = paste(message$data$username, "changed")
      )
      # if reset code wasn't valid
    } else {
      
      message_to_send <- RegLogConnectorMessage(
        "resetPass_confirm", success = FALSE, username = TRUE, code_valid = FALSE,
        logcontent = paste(message$data$username, "invalid code")
      )
    }
  }
  
  return(message_to_send)
  
}