#' @docType class
#'
#' @title Login and registration moduleServer
#' @description RegLogServer is an R6 class to use for handling the whole
#' backend of login and registration component of your shinyApp.
#'
#' @import R6
#' @export

RegLogServer <- R6::R6Class(
  "RegLogServer",
  
  public = list(
    #' @field is_logged logical indicating if the user is logged in
    is_logged = NULL,
    #' @field user_id character specifying the logged user identification name.
    #' If the user is not logged in, it will consist of timestamp prefixed with
    #' 'Anon'
    user_id = NULL,
    #' @field user_mail character containing the logged user mail. When not
    #' logged in, it is empty character string of `nchar()` with `length` of 0: `''`
    user_mail = NULL,
    #' @field message reactiveVal containing most recent RegLogConnectorMessage
    #' describing the latest change in the state of the system.
    message = NULL,
    #' @field module_id character storing ID for reglog_system module
    module_id = NULL,
    #' @field dbConnector `RegLogConnector` object used for communication with the
    #' database.
    dbConnector = NULL,
    #' @field mailConnector `RegLogConnector` object used for sending emails.
    mailConnector = NULL,
    
    #' @description Initialize 'ReglogServer' moduleServer
    #' 
    #' @param dbConnector object of class `RegLogConnector` handling the reads 
    #' from and writes to database.
    #' Two available in the package are `RegLogDBIConnector` and `RegLogGsheetsConnector`.
    #' See their documentation for more information about usage and creation of
    #' custom dbConnectors.
    #' @param mailConnector object of class `RegLogConnector` handling the email
    #' sending to the user for register confirmation and password reset.
    #' Two available in the package are `RegLogEmayiliConnector` and 
    #' `RegLogGmailrConnector`. See their documentation for more information
    #' about usage and creation of custom mailConnectors.
    #' @param app_name Name of the app to refer during correspondence to users.
    #' Defaults to the name of working directory.
    #' @param app_address URL to refer to during correspondence to users. If left
    #' at NULL, the URL will be parsed from `session$clientData`.
    #' @param lang character specyfiyng which language to use for all texts
    #' generated in the UI. Defaults to 'en' for English. Currently 'pl' for
    #' Polish is also supported.
    #' @param custom_txts named list containing character strings with custom
    #' messages. Defaults to NULL, so all built-in strings will be used.
    #' @param use_modals either logical indicating if all (`TRUE`) or none (`FALSE`)
    #' modalDialogs should be shown or character vector indicating which modals
    #' should be shown. For more information see details.
    #' @param module_id Character declaring the id of the module. Defaults to 'login_system'.
    #' Recommended to keep it that way, unless it would cause any namespace issues.
    
    initialize = function(
      dbConnector,
      mailConnector,
      app_name = basename(getwd()),
      app_address = NULL,
      lang = "en",
      custom_txts = NULL,
      use_modals = TRUE,
      module_id = "login_system"
    ) {
      
      # arguments check ####
      # RegLogConnectors
      if (!all(sapply(c(dbConnector, mailConnector), \(x) 'RegLogConnector' %in% class(x)))) {
        stop("Objects provided to 'dbConnector' and 'mailConnector' arguments should be of class 'RegLogConnector'.")
      }
      # app_address
      if (!is.null(app_address) && !is.character(app_address)) {
        stop("'app_address' should be either NULL or character")
      }
      # app_name
      if (!is.character(app_name) || length(app_name) > 1) {
        stop("'app_name' should be a single character string")
      }
      # lang
      if (!lang %in% reglog_texts$.languages_registered) {
        stop(paste("'lang' should be one of:", paste(reglog_texts$.languages_registered, collapse = ", ")))
      }
      # custom_txts
      if (!is.null(custom_txts)) {
        if (!"list" %in% class(custom_txts) || is.null(names(custom_txts)) ||
            sum(sapply(names(custom_txts), \(x) nchar(x) == 0)) > 0) {
          stop("Object provided to 'custom_txts' argument should be a named list")
        } else { # get custom txts into named list

        }
      }
      

      
      
      # save arguments into object ####
      self$module_id <- module_id
      self$dbConnector <- dbConnector
      self$mailConnector <- mailConnector
      private$custom_txts <- custom_txts
      private$app_name <- app_name
      private$lang <- lang
      if (!is.null(app_address)) {
        private$app_address <- app_address
      }
      
      # launch the module
      private$launch_module()
    }
    
  ),
  
  private = list(
    use_modals = NULL,
    lang = NULL,
    custom_txts = NULL,
    app_name = NULL,
    app_address = NULL,
    
    launch_module = function() {
      RegLogServer_frontend(self = self, private = private)
      RegLogServer_listener(self = self, private = private)
      RegLogServer_backend(self = self, private = private)
    }
  )
)

#' listener for RegLogServer
#' 
#' @details all reactivity of the server lies there
#' 
#' @param self object of R6
#' @param private object of R6
#' @noRd
#' @import shiny

RegLogServer_listener <- function(
  self,
  private
) {
  
  moduleServer(
    id = self$module_id, 
    function(input, output, session) {
      
      observe({
        
        # safety check - for the dbConnector to not be NULL
        req(!is.null(self$dbConnector))
        
        # receive the message
        received_message <- self$dbConnector$message()
        req(class(received_message) == "RegLogConnectorMessage")
        
        # switches for different reactions ####
        isolate({
          switch(
            received_message$type,
            
            # login messages reactions ####
            login = {
              # if couldn't log in
              if (!received_message$data$success) {
                # check what was the reason: 
                # user doesn't exist:
                if (!received_message$data$username) {
                  # show the modal if configuration allows
                  if (modals_check(private, "login_BadId")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nfound_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nfound_1")),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nforun_2")),
                                  footer = modalButton("OK")))
                  }
                  
                  # expose the message to the outside
                  self$message(received_message)
                } else {
                  # if the password is wrong
                  if (modals_check(private, "login_BadPass")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_wrong_pass_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_wrong_pass_b")),
                                  footer = modalButton("OK")))
                  }
                  
                  #expose the message to the outside
                  self$message(received_message)
                }
              } else {
                # if login is successful
                if (modals_check(private, "login_Success")) {
                  showModal(
                    modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_succ_t"),
                                p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_succ_b")),
                                footer = modalButton("OK")))
                }
                
                #expose the message to the outside
                self$message(received_message)
                
                # change the log-in state
                self$is_logged(TRUE)
                self$user_id(received_message$data$user_id)
                self$user_mail(received_message$data$user_mail)
                
              }
            },
            
            # register messages reactions ####
            register = {
              
              
              
              
              
            },
            
            # data edit messages reactions ####
            creds_edit = {
              
              
              
              
            },
            
            # reset password messages reactions ####
            
            resetpass = {
              
              
              
            }
            
          )
        })
      })
    })
}


#' FrontEnd for RegLogServer
#' 
#' @details Logic behind UI generation lies in there
#' 
#' @param self object of R6
#' @param private object of R6
#' @noRd
#' @import shiny

RegLogServer_frontend <- function(
  self,
  private
) {
  
  moduleServer(
    id = self$module_id, 
    function(input, output, session) {
      
      # render UI for login ####
      output$login_ui <- renderUI(
        tagList(h1("Login"),
            textInput(session$ns("login_user_id"),
                      label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="user_id")
            ),
            passwordInput(session$ns("password_login"),
                          label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="password")
            ),
            actionButton(session$ns("login_button"),
                         label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="login_bttn")
            )
        )
      )
      
      # render UI for registration ####
      output$register_ui <- renderUI(
        tagList(
          h1(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_ui_1")),
          p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_ui_2"),
            tags$ul(tags$li(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_ui_3")),
                    tags$li(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_ui_4")))),
          textInput(session$ns("register_user_ID"), 
                    label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="user_id")
          ),
          textInput(session$ns("register_email"), 
                    label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="email")
          ),
          passwordInput(session$ns("register_pass1"), 
                        label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="password")
          ),
          passwordInput(session$ns("register_pass2"), 
                        label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="password_rep")
          ),
          actionButton(session$ns("register_bttn"), 
                       label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_bttn")
          )
        )
      )
    }
  )
}

#' Backend for RegLogServer
#' 
#' @details Logic behind inter-module reactivity lies there
#' 
#' @param self object of R6
#' @param private object of R6
#' @noRd
#' @import shiny

RegLogServer_backend <- function(
  self,
  private
) {
  
  moduleServer(
    id = self$module_id, 
    function(input, output, session) {
      
      # initialize reactiveVals
      self$message <- reactiveVal()
      self$is_logged <- reactiveVal(FALSE)
      self$user_id <- reactiveVal(paste0("Anon", Sys.time()))
      self$user_mail <- reactiveVal("")
      
      # private$app_address <- get_url_shiny(session = getDefaultReactiveDomain())
      
      # login UI reactions ####
      
      observeEvent(input$login_button, {
        
        # try to log-in only when inputs are cantaining anything
        if (nchar(input$login_user_id) > 0 && nchar(input$password_login) > 0) {
          
          on.exit(.blank_textInputs(inputs = c("login_user_id", "password_login"),
                                    session = session))
          
          # send message
          message_to_sent <- RegLogConnectorMessage(
            type = "login",
            username = input$login_user_id,
            password = input$password_login
          )
          
          self$dbConnector$listener(message_to_sent)
          
        }
        
      })
      
      # register UI reactions ####
      
      
      
    }
  )
}