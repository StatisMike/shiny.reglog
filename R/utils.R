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
  
  isTRUE(private$use_modals) || (is.list(private$use_modals) && isTRUE(private$use_modals[[modalname]]))
  
}