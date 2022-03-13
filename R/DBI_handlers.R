#' DBI login handler
#' 
#' @description Default handler function querying database to confirm login 
#' procedure. Used within object of `RegLogDBIConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - password
#' @family DBI handler functions
#' @concept DBI_handler
#' @keywords internal

DBI_login_handler <- function(self, private, message) {
  
  check_namespace("DBI")
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE username = ?username;")
  query <- DBI::sqlInterpolate(private$db_conn, sql, username = message$data$username)
  
  user_data <- DBI::dbGetQuery(private$db_conn, query)
  
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

#' DBI register handler
#' 
#' @description Default handler function querying database to confirm registration 
#' validity and input new data. Used within object of `RegLogDBIConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - password
#' - email
#' @family DBI handler functions
#' @concept DBI_handler
#' @keywords internal

DBI_register_handler = function(self, private, message) {
  
  check_namespace("DBI")
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  # firstly check if user or email exists
  sql <- paste0("SELECT * FROM ", private$db_tables[1], 
                " WHERE username = ?username OR email = ?email;")
  query <- DBI::sqlInterpolate(private$db_conn, sql, 
                               username = message$data$username, 
                               email = message$data$email)
  
  user_data <- DBI::dbGetQuery(private$db_conn, query)
  
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
    # if query returns no data register new
    sql <- paste0("INSERT INTO ", private$db_tables[1], 
                  " (username, password, email, create_time, update_time)",
                  " VALUES (?username, ?password, ?email, ?create_time, ?create_time)")
    query <- DBI::sqlInterpolate(private$db_conn, sql, 
                                 username = message$data$username, 
                                 password = scrypt::hashPassword(message$data$password),
                                 email = message$data$email,
                                 create_time = db_timestamp())
    
    DBI::dbExecute(private$db_conn, query)
    # DBI::dbSendQuery(private$db_conn, query)
    
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

#' DBI edit to the database handler
#' 
#' @description Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogDBIConnector` class internally.
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
#' @family DBI handler functions
#' @concept DBI_handler
#' @keywords internal

DBI_credsEdit_handler <- function(self, private, message) {
  
  check_namespace("DBI")
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  # firstly check login credentials
  
  sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE username = ?username;")
  query <- DBI::sqlInterpolate(private$db_conn, sql, username = message$data$username)
  
  user_data <- DBI::dbGetQuery(private$db_conn, query)
  user_id <- user_data$id
  
  # check condition and create output message accordingly
  
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happens
    
    message_to_send <- RegLogConnectorMessage(
      "credsEdit", success = FALSE, username = FALSE, password = FALSE,
      logcontent = paste(message$data$username, "don't exist")
    )
    
  } else {
    # if there is a row present, check password
    
    if (isFALSE(scrypt::verifyPassword(user_data$password, message$data$password))) {
      # if FALSE: don't allow changes
      
      message_to_send <- RegLogConnectorMessage(
        "credsEdit", success = FALSE, username = TRUE, password = FALSE,
        logcontent = paste(message$data$username, "bad pass")
      )
      
    } else {
      # if TRUE: allow changes
      
      ## Additional checks: if unique values (username, email) that are to be changed
      ## are already present in the database
      
      # firsty parse veryfifying SQL query correctly
      verify <- ""
      
      if (!is.null(message$data$new_username)) {
        verify <- paste(verify ,"username = ?username", sep = if (nchar(verify) == 0) " " else " OR ")
      }
      if (!is.null(message$data$new_email)) {
        verify <- paste(verify, "email = ?email", sep = if (nchar(verify) == 0) " " else " OR ")
      }
      
      # if there is anything to verify...
      if (nchar(verify) > 0) {
        
        sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE ", verify, ";")
        
        # interpolate correct fields for check
        if (!is.null(message$data$new_username) && !is.null(message$data$new_email)) {
          query <- DBI::sqlInterpolate(private$db_conn, sql, 
                                       username = message$data$new_username,
                                       email = message$data$new_email)
        } else if (!is.null(message$data$new_username)) {
          query <- DBI::sqlInterpolate(private$db_conn, sql, 
                                       username = message$data$new_username)
        } else if (!is.null(message$data$new_email)) {
          query <- DBI::sqlInterpolate(private$db_conn, sql,
                                       email = message$data$new_email)
        }
        user_data <- DBI::dbGetQuery(private$db_conn, query)
      }
      
      # if something is returned, send fail back
      if (nchar(verify) > 0 && nrow(user_data) > 0) {
        
        message_to_send <- RegLogConnectorMessage(
          "credsEdit", success = FALSE,
          username = TRUE, password = TRUE,
          # if there is a conflict, these returns FALSE
          new_username = !isTRUE(message$data$new_username %in% user_data$username),
          new_email = !isTRUE(message$data$new_email %in% user_data$email))
        
        message_to_send$logcontent <-
          paste0(message$data$username, " conflict:",
                 if (!message_to_send$data$new_username) paste(" username:", message$data$new_username),
                 if (!message_to_send$data$new_email) paste(" email:", message$data$new_email), "." )
        
      } else {
        # if nothing is returned, update can be made!
        update_query <- paste("UPDATE", private$db_tables[1], "SET update_time = ?update_time")
        interpolate_vals <- list("update_time" = db_timestamp())
        # for every field to update popupalte query and interpolate vals
        if (!is.null(message$data$new_username)) {
          update_query <- paste(update_query, "username = ?username", sep = ", ")
          interpolate_vals[["username"]] <- message$data$new_username
        }
        if (!is.null(message$data$new_password)) {
          update_query <- paste(update_query, "password = ?password", sep = ", ")
          interpolate_vals[["password"]] <- scrypt::hashPassword(message$data$new_password)
        }
        if (!is.null(message$data$new_email)) {
          update_query <- paste(update_query, "email = ?email", sep = ", ")
          interpolate_vals[["email"]] <- message$data$new_email
        }
        update_query <- paste(update_query, "WHERE id = ?user_id;")
        interpolate_vals[["user_id"]] <- user_id
        
        query <- DBI::sqlInterpolate(private$db_conn, update_query,
                                     .dots = interpolate_vals)
        
        DBI::dbExecute(private$db_conn, query)
        
        message_to_send <- RegLogConnectorMessage(
          "credsEdit", success = TRUE,
          username = TRUE, password = TRUE,
          new_user_id = message$data$new_username,
          new_user_mail = message$data$new_email,
          new_user_pass = if(!is.null(message$data$new_password)) TRUE else NULL)
        
        info_to_log <- 
          c(message_to_send$data$new_user_id,
            message_to_send$data$new_user_mail,
            if (!is.null(message_to_send$new_user_pass)) "pass_change")
        
        message_to_send$logcontent <-
          paste(message$data$username, "updated",
                paste(info_to_log,
                      collapse = "/")
          )
      }
    }
  }
  
  return(message_to_send)
}


#' DBI resetpass code generation handler
#' 
#' @description Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogDBIConnector` class internally.
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which need to contain within its data:
#' - username
#' 
#' @family DBI handler functions
#' @concept DBI_handler
#' @keywords internal

DBI_resetPass_generation_handler <- function(self, private, message) {
  
  check_namespace("DBI")
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE username = ?;")
  query <- DBI::sqlInterpolate(private$db_conn, sql, message$data$username)
  
  user_data <- DBI::dbGetQuery(private$db_conn, query)
  
  # check condition and create output message accordingly
  
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happened
    
    message_to_send <- RegLogConnectorMessage(
      "resetPass_generate", success = FALSE, 
      logcontent = paste(message$data$username, "don't exist")
    )
    
    # if username exists, generate new resetpass code
  } else {
    
    reset_code <- paste(floor(stats::runif(10, min = 0, max = 9.9)), collapse = "")
    
    sql <- paste0("INSERT INTO ", private$db_tables[2], 
                  " (user_id, reset_code, used, create_time, update_time)",
                  " VALUES (?user_id, ?reset_code, 0, ?create_time, ?create_time)")
    query <- DBI::sqlInterpolate(private$db_conn, sql, 
                                 user_id = user_data$id,
                                 reset_code = reset_code,
                                 create_time = db_timestamp())

    DBI::dbExecute(private$db_conn, query)
    
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

#' DBI resetpass code confirmation handler
#' 
#' @description Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogDBIConnector` class internally.
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which need to contain within its data:
#' - username
#' - reset_code
#' - password
#' 
#' @family DBI handler functions
#' @concept DBI_handler
#' @keywords internal

DBI_resetPass_confirmation_handler <- function(self, private, message) {
  
  check_namespace("DBI")
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE username = ?;")
  query <- DBI::sqlInterpolate(private$db_conn, sql, message$data$username)
  
  user_data <- DBI::dbGetQuery(private$db_conn, query)
  
  # check condition and create output message accordingly
  
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happened
    
    message_to_send <- RegLogConnectorMessage(
      "resetPass_confirm", success = FALSE, username = FALSE, code_valid = FALSE,
      logcontent = paste(message$data$username, "don't exist")
    )
    
    # if username exists, check for the resetcode
  } else {
    
    sql <- paste0("SELECT * FROM ", private$db_tables[2], 
                  # matching reset code is found for this user_id
                  " WHERE user_id = ?user_id AND reset_code = ?reset_code",
                  # reset code is not used already
                  " AND used = 0;")
    
    query <- DBI::sqlInterpolate(private$db_conn, sql,
                                 user_id = user_data$id,
                                 reset_code = message$data$reset_code)
    
    reset_code_data <- DBI::dbGetQuery(private$db_conn, query)
    
    not_expired <- 
      (lubridate::as_datetime(reset_code_data$create_time) + lubridate::period(4, "hours")) > Sys.time()
    
    # if not used reset code matches and isn't expired, update the database
    if (nrow(reset_code_data) > 0 && not_expired) {
      
      # update user data
      sql <- paste0("UPDATE ", private$db_tables[1],
                    " SET password = ?password, update_time = ?update_time WHERE id = ?user_id")
      
      query <- DBI::sqlInterpolate(private$db_conn, sql,
                                   password = scrypt::hashPassword(message$data$password),
                                   update_time = db_timestamp(),
                                   user_id = user_data$id[1])
      
      DBI::dbExecute(private$db_conn, query)
      
      # update reset_code
      sql <- paste0("UPDATE ", private$db_tables[2],
                    " SET used = 1, update_time = ?update_time WHERE id = ?reset_code_id")
      
      query <- DBI::sqlInterpolate(private$db_conn, sql,
                                   update_time = db_timestamp(),
                                   reset_code_id = reset_code_data$id[1])

      DBI::dbExecute(private$db_conn, query)
      
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
