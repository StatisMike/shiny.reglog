#' @docType class
#' 
#' @title RegLog connector template
#' @description Parent class for all RegLog connectors
#' @import R6
#' @export

RegLogConnector = R6::R6Class(
  "RegLogConnector",
  # public elements ####
  public = list(
    #' @field module_id character vector specifying the automatically-generated
    #' module_id for listener server module
    module_id = NULL,
    
    #' @field listener reactiveVal that the object keeps listening of changes for
    listener = NULL,
    
    #' @field message reactiveVal containing outward message
    message = NULL,
    
    #' @field log list containing data about received and sent messages by the object
    log = list(),
    
    #' @field handlers named list containing functions used to handle different
    #' types of `RegLogConnectorMessage`. Name of the element corresponds to 
    #' the 'type' that is should handle.
    #' @details You can specify custom handler functions as a named list passed
    #' to `custom_handlers` arguments during object initialization. Custom handler
    #' should take arguments: `self` and `private` - relating to the R6 object
    #' and `message` of class `RegLogConnectorMessage`. It should return
    #' return `RegLogConnectorMessage` object
    
    handlers = list(
      ping = function(self, private, message) {
        
        RegLogConnectorMessage(
          "ping",
          response_time = as.numeric(lubridate::as_datetime(db_timestamp()) - lubridate::as_datetime(message$time)),
          logcontent = if (!is.null(message$logcontent)) message$logcontent else ""
        )
      }
    ),
    
    #' @description Function to receive all saved logs from the object in the form
    #' of single data.frame
    #' @return data.frame
    
    get_logs = function() {
      
      binded_logs <- list()
      
      for (i in seq_along(self$log)) {
        
        binded_logs[[names(self$log)[i]]] <-
          data.table::rbindlist(self$log[[i]], idcol = "time")
        
      }
      
      binded_logs <- data.table::rbindlist(binded_logs, idcol = "direction")
      binded_logs <- as.data.frame(binded_logs[order(binded_logs$time),])
      
    },
    
    #' @description Initialization of the object. Sets up listener reactiveVal
    #' and initializes listening server module
    #' @param custom_handlers named list of custom handler functions. Custom handler
    #' should take arguments: `self` and `private` - relating to the R6 object
    #' and `message` of class `RegLogConnectorMessage`. It should return
    #' return `RegLogConnectorMessage` object.
    #' 
    #' @return object of `RegLogConnector` class
    
    initialize = function(
      custom_handlers = NULL
    ) {
      # assign the unique ID for the module
      self$module_id <- uuid::UUIDgenerate()
      
      # assign custom handlers if any present
      if (!is.null(custom_handlers)) {
        ## checks if the custom_handlers are correct
            ## custom handlers should be a list
        if (class(custom_handlers) == "list" &&
            ## all elements of it needs to be named
            all(sapply(names(custom_handlers), \(x) nchar(x) > 0)) &&
            ## all elements need to be of class 'function'
            all(sapply(custom_handlers, \(x) "function" %in% class(x)))
            ) {
          
          for (handler_n in seq_along(custom_handlers)) {
            # assign every custom handler in the self$objects
            self$handlers[[names(custom_handlers)[handler_n]]] <-
              custom_handlers[[handler_n]]
          }
          
        } else {
          stop("Object passed to the 'custom_handlers' should be a named list containing functions.")
        }
      }
      
      # initialize listener
      self$listener <- reactiveVal(
        RegLogConnectorMessage("ping", logcontent = "init")
      )
      # initialize message
      self$message <- reactiveVal(
        RegLogConnectorMessage("ping", logcontent = "init")
      )
      # begin listening to the changes
      private$listen(self, private)
    },
    
    #' @description Suspend the listening to the changes
    suspend = function() {
      if (!is.null(private$o) && isFALSE(private$o$.suspended))
      private$o$suspend()
    },
    
    #' @description Resume the listening to the changes
    resume = function() {
      if (!is.null(private$o) && isTRUE(private$o$.suspended))
      private$o$resume()
    }
    
  ),
  private = list(
    
    # observer of listening moduleServer
    o = NULL,
    # moduleServer that listens and reacts to changes in `RegLogServer`
    listen = function(self,
                      private) {
      
      moduleServer(id = self$module_id,
                   
                   function(input, output, session) {
                     
                     private$o <- observe({
                       # receive the message
                       received_message <- self$listener()
                       # reacts only on certain objects passed to its listener
                       req(class(received_message) == "RegLogConnectorMessage" &&
                             received_message$type %in% names(self$handlers))
                       isolate({
                         # save received message to the logs
                         save_to_logs(received_message,
                                      "received",
                                      self,
                                      session)
                         # self$log[[format(received_message$time, digits=15)]] <-
                         #   data.frame(session = session$token,
                         #              direction = "received",
                         #              type = as.character(received_message$type),
                         #              note = if(is.null(received_message$logcontent)) "" else as.character(received_message$logcontent))
                         # call function, passing received message into it and assign
                         # returning message to sent
                         message_to_send <-
                           self$handlers[[
                             # call function associated with correct message
                             received_message$type
                           ]](self = self,
                              private = private,
                              message = received_message)
                         
                         # save sent message to the logs
                         save_to_logs(received_message,
                                      "sent",
                                      self,
                                      session)
                         # self$log[[format(message_to_send$time, digits=15)]] <-
                         #   data.frame(session = session$token,
                         #              direction = "sent",
                         #              type = as.character(message_to_send$type),
                         #              note = if(is.null(message_to_send$logcontent)) "" else as.character(message_to_send$logcontent))
                         
                         # send message to the reactiveVal
                         self$message(message_to_send)
                       })
                     })
                   })
    }
    
  )
)

#' @title create RegLogConnectorMessage object
#' 
#' @description Create an object of ReglogConnectorMessage class. It is used
#' to send data to objects that inherit their class from `RegLogConnector`
#' 
#' @param type character string declaring the type of message
#' @param ... named arguments that will be passed as data
#' @param logconent character string. Optional description to save into logs.
#' 
#' @return object of `RegLogConnector` class, containing fields:
#' 
#' - *time*: numeric representation of `Sys.time()`
#' - *type*: character specifying the type of message
#' - *data*: list of values that are to be sent alongside the message
#' - *logcontent*: Character string with information to be saved in logs. Optional.
#' 
#' @export

RegLogConnectorMessage <- function(
  type,
  ...,
  logcontent = NULL
) {
  
  x <- list(
    time = db_timestamp(),
    type = as.character(type[1]),
    data = list(...),
    logcontent = logcontent
  )
  
  class(x) <- "RegLogConnectorMessage"
  
  return(x)
  
}
