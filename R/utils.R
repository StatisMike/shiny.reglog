check_namespace <- function(package) {
  if (!requireNamespace(package, quietly = T)) {
    stop(call. = F, 
         paste0("To use this functionality, you need to additionally install package: '",
                package,
                "'. You can do it by typing `install.packages('",
                package, "')`."))
  }
}

blank_textInputs <- function(inputs, session){
  for(input in inputs){
    
    updateTextInput(session,
                    inputId = input,
                    value = "")
    
  }
}

get_url_shiny <- function(session) {
  
  clientData <- reactiveValuesToList(session$clientData)
  
  path <- c()
  path <- paste(clientData$url_protocol,
                clientData$url_hostname,
                sep = "//")
  
  if (!is.null(clientData$url_port))
    path <- paste(path, clientData$url_port, sep = ":")
  
  return(paste0(path, clientData$url_pathname))
  
}

modals_check_n_show <- function(private, modalname) {
  
  if (isTRUE(private$use_modals) || (is.list(private$use_modals) && !isFALSE(private$use_modals[[modalname]]))) {
    showModal(
      modalDialog(title = RegLog_txt(lang = private$lang, custom_txts = private$custom_txts, x = paste(modalname, "t", sep = "_")),
                  p(RegLog_txt(lang = private$lang, custom_txts = private$custom_txts, x = paste(modalname, "b", sep = "_"))),
                  footer = modalButton("OK"))
    )
  }
  
}

check_user_login <- function(x){
  nchar(x) >= 8 & nchar(x) <= 30 & grepl("^[[:alnum:]]+$", x)
}

check_user_pass <- function(x){
  pass_length <- nchar(x) >= 8 & nchar(x) <= 30
  small_letter <- stringi::stri_detect(str = x, regex = "(?=.*[a-z])")
  big_letter <- stringi::stri_detect(str = x, regex = "(?=.*[A-Z])")
  pass_number <- stringi::stri_detect(str = x, regex = "(?=.*\\d)")
  pass_symbols <- stringi::stri_detect(str = x, regex = "[-+_!@#$%^&*.,?]")
  
  pass_length && sum(small_letter, big_letter, pass_number, pass_symbols) >= 3
}

check_user_mail <- function(x) {
  grepl("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z-a-z]{2,}$", as.character(x))
}

#' function to save message to logs
#' @param message reveived message
#' @param direction either received or sent
#' @param self R6 object
#' @param session shiny object
#' @param no_db boolean: if TRUE, then inhibits inputing into database. 
#' Defaults to FALSE
#' @noRd

save_to_logs <- function(message, direction, self, session, no_db = F) {

  # check options
  if (direction %in% c("sent", "received")) {
    log_save <- getOption("RegLogServer.logs", 1) >= 1
    log_input <- getOption("RegLogServer.logs_to_database", 0) >= 1
  } else if (direction == "shown") {
    log_save <- getOption("RegLogServer.logs", 1) >= 2
    log_input <- getOption("RegLogServer.logs_to_database", 0) >= 2
  }
  
  # if log is to be saved into self$log
  if (log_save) {
    self$log[[as.character(direction)]][[message$time]] <-
      data.frame(session = session$token,
                 type = as.character(message$type),
                 note = if(is.null(message$logcontent)) "" else as.character(message$logcontent))
  }
  
  # if log is to be input into the database
  if (log_input && isFALSE(no_db)) {
    if (!is.null(self$dbConnector)) {
          self$dbConnector$.__enclos_env__$private$input_log(
      message = message,
      direction = direction,
      session = session)
    }
  }
}

#' function to replace multiple values in string
#' @param x string to make replacements on
#' @param to_replace named list of character strings to replace
#' @noRd

string_interpolate <- function(x, to_replace) {
  
  look_for <- paste0("?", names(to_replace), "?")
  
  for (i in seq_along(look_for)) {
    if (!is.null(to_replace[[i]])) {
      x <- gsub(x = x, pattern = look_for[i], replacement = to_replace[[i]], fixed = T)
    }
  }
  
  return(x)
}

#' function to create standardized timestamp
#'
#' @export

db_timestamp <- function() {
  
  format(Sys.time(), format = "%Y-%m-%d %H:%M:%OS3")
  
}
