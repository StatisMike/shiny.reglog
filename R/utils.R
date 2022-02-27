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

modals_check <- function(private, modalname) {
  
  isTRUE(private$use_modals) || (is.list(private$use_modals) && !isFALSE(private$use_modals[[modalname]]))
  
}

check_user_login <- function(x){
  nchar(x) >= 8 & nchar(x) <= 25 & grepl("^[[:alnum:]]+$", x)
}

check_user_pass <- function(x){
  nchar(x) >= 8 & nchar(x) <= 25 & grepl("^[[:alnum:]]+$", x)
}

check_user_mail <- function(x) {
  grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", as.character(x), ignore.case=TRUE)
}

#' function to save message to logs
#' @param message reveived message
#' @param direction either received or sent
#' @param self R6 object
#' @param session shiny object
#' @noRd

save_to_logs <- function(message, direction, self, session) {
  
  self$log[[as.character(direction)]][[format(message$time, digits=15)]] <-
    data.frame(session = session$token,
               type = as.character(message$type),
               note = if(is.null(message$logcontent)) "" else as.character(message$logcontent))
  
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

#' function to create SQL-friendly time format
#' @noRd

SQL_timestamp <- function() {
  
  format(Sys.time(), format = "%Y-%m-%d %H:%M:%OS3")
  
}
