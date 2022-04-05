#' @title Create RegLog-valid database collections for MongoDB
#' 
#' @description 
#' `r lifecycle::badge("experimental")`
#' 
#' MongoDB database don't enforce a structure to the documents contained within.
#' Even though this is true, it's best to use this function explicitly, 
#' as after creation of collections it also create appropriate indexes for quick 
#' querying of the database by RegLogMongoConnector.
#' 
#' @param mongo_url URI to the MongoDB cluster
#' @param mongo_db name of the MongoDB database 
#' @param mongo_options additional connection options such as SSL keys/certs
#' @param account_name Name of the collection for storing user accounts credentials. 
#' Defaults to 'account'. Mandatory collection.
#' @param reset_code_name Name of the collector for storing generated password reset
#' codes. Defaults to 'reset_code'. Mandatory collection.
#' @param user_data If you wish to import existing user database, you can input
#' data.frame with that table in this argument. It should contain columns:
#' username, password, email (ond optionally: create_time). Defaults to NULL.
#' @param hash_passwords If you are importing table of users upon tables creation,
#' you can also specify if the password should be hashed using `scrypt::hashPassword`.
#' Defaults to `FALSE`. If you have unhashed passwords in imported table, set
#' this option to `TRUE`.
#' @param verbose Boolean specific if the actions made by function should be
#' printed back to the console. 
#' 
#' @details 
#' Every document in created collections will have following structure:
#' 
#' - account (default name)
#'   - username: character **(index)**
#'   - password: character 
#'   - email: character **(index)**
#'   - create_time: timestamp
#'   - update_time: timestamp
#' - reset_code (default name)
#'   - user_id: character **(index)**
#'   - reset_code: character
#'   - used: numeric
#'   - create_time: timestamp
#'   - update_time: timestamp
#' - logs (default name, optional) - this collection isn't created with this
#' function, as there is no need for that - MongoDB collections don't have a 
#' set structure, and no additional index is created there.
#'   - time: timestamp
#'   - session: character
#'   - direction: character
#'   - type: character
#'   - note: character
#' 
# @example examples/mongo_tables_create.R
#' @export
#' @family RegLog databases

mongo_tables_create <- function(
  mongo_url,
  mongo_db,
  mongo_options = mongolite::ssl_options(),
  account_name = "account",
  reset_code_name = "reset_code",
  user_data = NULL,
  hash_passwords = FALSE,
  verbose = TRUE
){
  
  check_namespace("mongolite")
  
  # if user data is provided, check its validity
  if (!is.null(user_data)) {
    check_user_data(user_data)
  }
  
  # parse tables to write
  tables <- list()
  
  # table with user data
  if (!is.null(user_data)) {
    if (isTRUE(hash_passwords)) {
      if (isTRUE(verbose)) {
        writeLines(paste0("Hashing passwords from existing data."))
        hash_progress <- utils::txtProgressBar(min = 0, max = nrow(user_data), initial = 0,
                                               style = 3)
      }
      # iteratively hash passwords
      for (i in seq_along(user_data$password)) {
        user_data$password[i] <- scrypt::hashPassword(user_data$password[i])
        if (isTRUE(verbose)) {
          utils::setTxtProgressBar(hash_progress, value = i)
        }
      }
      if (isTRUE(verbose)) close(hash_progress)
    }
    db_time <- db_timestamp()
    user_data$create_time <- if (is.null(user_data$create_time)) db_time 
                           else lubridate::as_datetime(user_data$create_time)
    user_data$update_time <- db_time

    # insert parsed data
    mongo_conn <- mongolite::mongo(
      url = mongo_url,
      db = mongo_db,
      options = mongo_options,
      collection = account_name
    )
    
    mongo_conn$insert(user_data)
    
  } else {
    # create collection
    mongo_conn <- mongolite::mongo(
      url = mongo_url,
      db = mongo_db,
      options = mongo_options,
      collection = account_name
    )
  }
  # create indexes and disconnect from collection
  mongo_conn$index("username")
  mongo_conn$index("email")
  mongo_conn$disconnect()
  if (isTRUE(verbose)) {
    writeLines(paste0(account_name, " collection created"))
  }
  
  # create idexes for reset_codes
  mongo_conn <- mongolite::mongo(
    url = mongo_url,
    db = mongo_db,
    options = mongo_options,
    collection = reset_code_name
  )
  mongo_conn$index("user_id")
  mongo_conn$disconnect()
  if (isTRUE(verbose)) {
    writeLines(paste0(reset_code_name, " collection created"))
  }
}


#' @docType class
#' @title Connector to MongoDB database
#' @description 
#' `r lifecycle::badge("experimental")`
#' 
#' Object of this class handles all connections for the RegLogServer object to 
#' the database. It is created to handle MongoDB database compatible drivers. 
#' Provides methods than will be used by RegLogServer to get and send data.
#' 
#' Requires `mongolite` package to be installed.
#' @export

RegLogMongoConnector <- R6::R6Class(
  "RegLogMongoConnector",
  inherit = RegLogConnector,
  
  public = list(
    
    #' @description Initialization of the object
    #' @param mongo_url URI to the MongoDB cluster
    #' @param mongo_db name of the MongoDB database 
    #' @param mongo_options additional connection options such as SSL keys/certs
    #' @param collections names of the collections 
    #' @param table_names character vector. Contains names of the collections in the
    #' database: first containing user data, second - reset codes information,
    #' third (optional) - logs from the object. For more info check documentation
    #' of `mongo_database_create`.
    #' @param custom_handlers named list of custom handler functions. Every 
    #' custom handler should take arguments: `self` and `private` - relating to 
    #' the R6 object and `message` of class `RegLogConnectorMessage`. It should 
    #' return `RegLogConnectorMessage` object.
    #' @return Object of `RegLogMongoConnector` class
    
    initialize = function(
      mongo_url,
      mongo_db,
      mongo_options = mongolite::ssl_options(),
      collections = c("account", "reset_code", "logs"),
      custom_handlers = NULL
    ) {
      check_namespace("mongolite")
      
      self$handlers[["login"]] <- mongo_login_handler
      self$handlers[["register"]] <- mongo_register_handler
      self$handlers[["credsEdit"]] <- mongo_credsEdit_handler
      self$handlers[["resetPass_generate"]] <- mongo_resetPass_generation_handler
      self$handlers[["resetPass_confirm"]] <- mongo_resetPass_confirmation_handler
      
      super$initialize(custom_handlers = custom_handlers)
      
      # store the arguments internally
      private$mongo_url <- mongo_url
      private$mongo_db <- mongo_db
      private$mongo_options <- mongo_options
      private$collections <- collections
      
    }
    
  ),
  
  private = list(
    mongo_url = NULL,
    mongo_db = NULL,
    mongo_options = NULL,
    collections = NULL,
    connect = function(collection) {
      
      mongolite::mongo(url = private$mongo_url,
                       db = private$mongo_db,
                       options = private$mongo_options,
                       collection = collection)
    }
  )
)

### RegLogMongoConnector handler functions ####

#' MongoDB login handler
#' 
#' @description 
#' `r lifecycle::badge("experimental")`
#' 
#' Default handler function querying database to confirm login 
#' procedure. Used within object of `RegLogMongoConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - password
#' @family MongoDB handler functions
#' @concept mongo_handler
#' @keywords internal

mongo_login_handler <- function(self, private, message) {
  
  check_namespace("mongolite")
  
  account <- private$connect(private$collections[1])
  on.exit(account$disconnect())
  
  # search for user
  user_data <- account$find(
    query = jsonlite::toJSON(list(username = message$data$username), auto_unbox = T),
    fields = '{}'
  )
  
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
        account_id = user_data$`_id`,
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

#' MongoDB register handler
#' 
#' @description 
#' `r lifecycle::badge("experimental")`
#' 
#' Default handler function querying database to confirm registration 
#' validity and input new data. Used within object of `RegLogMongoConnector` class internally.
#' 
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which should contain within its data:
#' - username
#' - password
#' - email
#' @family MongoDB handler functions
#' @concept mongo_handler
#' @keywords internal

mongo_register_handler = function(self, private, message) {
  
  check_namespace("mongolite")
  
  account <- private$connect(private$collections[1])
  on.exit(account$disconnect())
  
  # firstly check if user or email exists
  user_data <- account$find(
    jsonlite::toJSON(list(
      "$or" = list(list(username = message$data$username), list(email = message$data$email))), 
      auto_unbox = T))
  
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
    account$insert(
      data.frame(
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

#' MongoDB edit to the database handler
#' 
#' @description 
#' `r lifecycle::badge("experimental")`
#' 
#' Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogMongoConnector` class internally.
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which need to contain within its data:
#' - account_id
#' - password
#' 
#' It can also contain elements for change:
#' - new_username
#' - new_email
#' - new_password
#' @family MongoDB handler functions
#' @concept mongo_handler
#' @keywords internal

mongo_credsEdit_handler <- function(self, private, message) {
  
  check_namespace("mongolite")
  
  account <- private$connect(private$collections[1])
  on.exit(account$disconnect())
  
  # firstly check login credentials
  user_data <- account$find(
    query = jsonlite::toJSON(list(
      "_id" = list("$oid" = message$data$account_id)
    ), auto_unbox = T))
  
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
    conflicting <- account$find(
      jsonlite::toJSON(list("$or" = list(list(username = message$data$new_username),
                                         list(email = message$data$new_email))),
                       auto_unbox = T))
    
    if (nrow(conflicting) > 0) {
      message_to_send <- RegLogConnectorMessage(
        "credsEdit", success = FALSE,
        password = TRUE,
        # if there is a conflict, these returns FALSE
        new_username = !isTRUE(message$data$new_username %in% conflicting$username),
        new_email = !isTRUE(message$data$new_email %in% conflicting$email))
      
      message_to_send$logcontent <-
        paste0(user_data$username, " conflict:",
               if (!message_to_send$data$new_username) paste(" username:", message$data$new_username),
               if (!message_to_send$data$new_email) paste(" email:", message$data$new_email), "." )
    } else {
      # if nothing is returned, update can be made!
      to_update <- list()
      
      if (!is.null(message$data$new_username)) {
        to_update[["username"]] = message$data$new_username
      }
      if (!is.null(message$data$new_email)) {
        to_update[["email"]] = message$data$new_email
      }
      if (!is.null(message$data$new_password)) {
        to_update[["password"]] = scrypt::hashPassword(message$data$new_password)
      }
      
      account$update(
        query = jsonlite::toJSON(list(
          "_id" = list("$oid" = message$data$account_id)
        ), auto_unbox = T),
        update = jsonlite::toJSON(list("$set" = to_update), auto_unbox = T)
      )
      
      message_to_send <- RegLogConnectorMessage(
        "credsEdit", success = TRUE,
        password = TRUE,
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

#' MongoDB resetpass code generation handler
#' 
#' @description 
#' `r lifecycle::badge("experimental")`
#' 
#' Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogMongoConnector` class internally.
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which need to contain within its data:
#' - username
#' 
#' @family MongoDB handler functions
#' @concept mongo_handler
#' @keywords internal

mongo_resetPass_generation_handler <- function(self, private, message) {
  
  check_namespace("mongolite")
  
  account <- private$connect(private$collections[1])
  on.exit(account$disconnect())

  # firstly check login credentials
  user_data <- account$find(
    query = jsonlite::toJSON(list("username" = message$data$username),
                             auto_unbox = T),
    fields = '{}')
  
  # check condition and create output message accordingly
  
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happened
    
    message_to_send <- RegLogConnectorMessage(
      "resetPass_generate", success = FALSE, 
      logcontent = paste(message$data$username, "don't exist")
    )
    
    # if username exists, generate new resetpass code
  } else {
    
    resetCode <- private$connect(private$collections[2])
    on.exit(resetCode$disconnect(), add = T)
    
    # get the user id
    user_id <- user_data$`_id`
    reset_code <- paste(floor(stats::runif(10, min = 0, max = 9.9)), collapse = "")
    
    data_to_append <- data.frame(
      user_id = user_id,
      reset_code = reset_code,
      user = 0,
      create_time = db_timestamp(),
      update_time = db_timestamp()
    )
    
    resetCode$insert(data_to_append)
    
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

#' MongoDB resetpass code confirmation handler
#' 
#' @description 
#' `r lifecycle::badge("experimental")`
#' 
#' Default handler function querying database to confirm credentials
#' edit procedure and update values saved within database. Used within object of 
#' `RegLogMongoConnector` class internally.
#' @param self R6 object element
#' @param private R6 object element
#' @param message RegLogConnectorMessage which need to contain within its data:
#' - username
#' - reset_code
#' - password
#' 
#' @family MongoDB handler functions
#' @concept mongo_handler
#' @keywords internal

mongo_resetPass_confirmation_handler <- function(self, private, message) {
  
  check_namespace("mongolite")
  
  browser()
  
  account <- private$connect(private$collections[1])
  on.exit(account$disconnect())
  
  user_data <- account$find(
    query = jsonlite::toJSON(list("username" = message$data$username),
                             auto_unbox = T),
    fields = '{}')
  
  # check condition and create output message accordingly
  if (nrow(user_data) == 0) {
    # if don't return any, then nothing happened
    
    message_to_send <- RegLogConnectorMessage(
      "resetPass_confirm", success = FALSE, username = FALSE, code_valid = FALSE,
      logcontent = paste(message$data$username, "don't exist")
    )
    
    # if username exists, check for the resetcode
  } else {
    
    resetCode <- private$connect(private$collections[2])
    on.exit(resetCode$disconnect(), add = T)
    
    user_id <- user_data$`_id`
    reset_code_data <- resetCode$find(
      query = jsonlite::toJSON(list(user_id = user_id, reset_code = message$data$reset_code),
                               auto_unbox = T),
      fields = '{}')
    
    not_expired <- 
      (lubridate::as_datetime(reset_code_data$create_time) + lubridate::period(4, "hours")) > Sys.time()
    
    # if not used reset code matches and isn't expired, update the database
    if (nrow(reset_code_data) > 0 && not_expired) {

      # update user data
      account$update(
        query = jsonlite::toJSON(list(
          "_id" = list("$oid" = user_id)
        ), auto_unbox = T),
        update = jsonlite::toJSON(list("$set" = list(
          password = scrypt::hashPassword(message$data$password),
          update_time = db_timestamp()
        )), auto_unbox = T))
      
      # update reset code
      resetCode$update(
        query = jsonlite::toJSON(list(
          "_id" = list("$oid" = reset_code_data$`_id`)
        ), auto_unbox = T),
        update = jsonlite::toJSON(list("$set" = list(
          used = 1,
          update_time = db_timestamp()
        )), auto_unbox = T))
      
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