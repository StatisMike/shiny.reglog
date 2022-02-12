#' DBI login handler
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - password
#' @family DBI handler functions

DBI_login_handler <- function(self, private, message) {
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE username = ?;")
  query <- DBI::sqlInterpolate(private$db_conn, sql, message$data$username)
  
  user_data <- DBI::dbGetQuery(private$db_conn, query)
  
  # check condition and create output message accordingly
  
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happened
    
    RegLogConnectorMessage(
      "login", username = FALSE, password = FALSE,
      logcontent = paste(message$data$username, "don't exist")
    )
    
  } else {
    # if there is a row present, check password
    
    if (scrypt::verifyPassword(user_data$password, message$data$password)) {
      # if success: user logged in
      
      RegLogConnectorMessage(
        "login", username = TRUE, password = TRUE,
        logcontent = paste(message$data$username, "logged in")
      )
      
    } else {
    
      RegLogConnectorMessage(
        "login", username = TRUE, password = FALSE,
        logcontent = paste(message$data$username, "bad pass")
      )
    }
  }
}

#' DBI register handler
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - password
#' - email
#' @family DBI handler functions

DBI_register_handler = function(self, private, message) {
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  # firstly check if user or email exists
  sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE username = ? OR email = ?;")
  query <- DBI::sqlInterpolate(private$db_conn, sql, message$data$username, message$data$email)
  
  user_data <- DBI::dbGetQuery(private$db_conn, query)
  
  if (nrow(user_data) > 0) {
    # if query returns data don't register new
      RegLogConnectorMessage(
        "register", 
        success = FALSE, 
        username = message$data$username %in% user_data$username,
        email = message$data$email %in% user_data$email,
        logcontent = paste(message$data$username, "or", message$data$email, "in db")
      )
  } else {
    # if query returns no data register new
    sql <- paste0("INSERT INTO ", private$db_tables[1], 
                  " (username, password, email, create_time, modify_time) VALUES (?, ?, ?, ?, ?)")
    query <- DBI::sqlInterpolate(private$db_conn, sql, 
                                 message$data$username, 
                                 scrypt::hashPassword(message$data$password),
                                 message$data$email,
                                 as.character(Sys.time()),
                                 as.character(Sys.time()))
    
    DBI::dbSendQuery(private$db_conn, query)
    
    RegLogConnectorMessage(
      "register", 
      success = TRUE, 
      logcontent = paste(message$data$username, "with", message$data$email, "registered")
    )
  }
}

#' DBI edit to the database handler
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

DBI_creds_edit_handler <- function(self, private, message) {
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  # firstly check login credentials
  
  sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE username = ?;")
  query <- DBI::sqlInterpolate(private$db_conn, sql, message$data$username)
  
  user_data <- DBI::dbGetQuery(private$db_conn, query)
  user_id <- user_data$id
  
  # check condition and create output message accordingly
  
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happens
    
    RegLogConnectorMessage(
      "creds_edit", success = FALSE, username = FALSE, password = FALSE,
      logcontent = paste(message$data$username, "don't exist")
    )
    
  } else {
    # if there is a row present, check password
    
    if (isFALSE(scrypt::verifyPassword(user_data$password, message$data$password))) {
      # if FALSE: don't allow changes
      
      RegLogConnectorMessage(
        "creds_edit", success = FALSE, username = TRUE, password = FALSE,
        logcontent = paste(message$data$username, "bad pass")
      )
      
    } else {
      # if TRUE: allow changes
      
      ## Additional checks: if unique values (username, email) that are to be changed
      ## are already present in the database
      
      # firsty parse veryfifying SQL query correctly
      verify <- ""
      
      if (!is.null(message$data$new_username)) {
        verify <- paste(verify ,"username = ?", sep = if (nchar(verify) == 0) " " else " OR ")
      }
      if (!is.null(message$data$new_email)) {
        verify <- paste(verify, "email = ?", sep = if (nchar(verify) == 0) " " else " OR ")
      }
      
      # if there is anything to verify...
      if (nchar(verify) > 0) {
        
        sql <- paste0("SELECT * FROM ", private$db_tables[1], " WHERE ", verify, ";")
        
        # interpolate correct fields for check
        if (!is.null(message$data$new_username) && !is.null(message$data$new_username)) {
          query <- DBI::sqlInterpolate(private$db_conn, sql, 
                                       message$data$new_username,
                                       message$data$new_email)
        } else if (!is.null(message$data$new_username)) {
          query <- DBI::sqlInterpolate(private$db_conn, sql, 
                                       message$data$new_username)
        } else if (!is.null(message$data$new_email)) {
          query <- DBI::sqlInterpolate(private$db_conn, sql,
                                       message$data$new_email)
        }
        user_data <- DBI::dbGetQuery(private$db_conn, query)
        # if something is returned, send fail back
        if (nrow(user_data) > 0) {
          
          message_to_send <- RegLogConnectorMessage(
            "creds_edit", success = FALSE,
            username = TRUE, password = TRUE,
            # if there is a conflict, these returns FALSE
            new_username = !isTRUE(message$data$new_username %in% user_data$username),
            new_email = !isTRUE(message$data$new_email %in% user_data$email))
          
          message_to_send$logcontent <-
            paste0(message$data$username, " conflict:",
                   if (!message_to_send$data$new_username) " username",
                   if (!message_to_send$data$new_email) " email", "." )
          
          message_to_send

        } else {
          # if nothing is returned, update can be made!
          update_query <- paste("UPDATE", private$db_tables[1], "SET modify_time = ?modify_time")
          interpolate_vals <- list("modify_time" = as.character(Sys.time()))
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
          
          DBI::dbSendQuery(private$db_conn, query)
          
          RegLogConnectorMessage(
            "creds_edit", success = TRUE,
            username = TRUE, password = TRUE,
            logcontent = paste(message$data$username, "updated",
                                paste(names(interpolate_vals)[c(-1, -length(interpolate_vals))],
                                      collapse = ", "))
          )
        }
      }
    }
  }
}