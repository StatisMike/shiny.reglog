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
    db_time <- lubridate::as_datetime(db_timestamp())
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
      
      # self$handlers[["login"]] <- mongo_login_handler
      # self$handlers[["register"]] <- mongo_register_handler
      # self$handlers[["credsEdit"]] <- mongo_credsEdit_handler
      # self$handlers[["resetPass_generate"]] <- mongo_resetPass_generation_handler
      # self$handlers[["resetPass_confirm"]] <- mongo_resetPass_confirmation_handler
      
      super$initialize(custom_handlers = custom_handlers)
      
      # store the arguments internally
      private$mongo_url <- mongo_url
      private$mongo_db <- mongo_db
      private$mongo_options <- mongo_options
      private$collections <- collections
      
    }
    
  ),
  
  private = list(
    url = NULL,
    db = NULL,
    collections = NULL
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
#' - username
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
  
}