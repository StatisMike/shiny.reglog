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
      
      # observe changes in internal listener ####
      observe({
        
        req(!is.null(private$listener))
        # receive the message
        received_message <- private$listener()
        req(class(received_message) == "RegLogConnectorMessage") 
        req(received_message$type %in% c("logout"))
        # save the message to the logs
        save_to_logs(received_message,
                     "received",
                     self,
                     session)        
        
        ## switches for different reactions ####
        isolate({
          switch(
            received_message$type,
            
            ## logout messages reactions ####
            logout = {
              
              if (modals_check(private, "logout")) {
                showModal(
                  modalDialog(
                    title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "logout_mod_t"),
                    tags$p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "logout_mod_b")),
                    footer = modalButton("OK")
                  )
                )
              }
              
              # clear user data
              self$is_logged <- reactiveVal(FALSE)
              self$user_id <- reactiveVal(uuid::UUIDgenerate())
              self$user_mail <- reactiveVal("")
              #expose the message to the outside
              self$message(received_message)
            }
          )
        })
      })
      
      # observe changes in dbConnector ####
      observe({
        
        # safety check - for the dbConnector to not be NULL
        req(!is.null(self$dbConnector))
        
        # receive the message
        received_message <- self$dbConnector$message()
        req(class(received_message) == "RegLogConnectorMessage")
        req(!received_message$type %in% c("logout"))
        
        ## switches for different reactions ####
        isolate({
          # save the received message to logs
          save_to_logs(received_message,
                       "received",
                       self,
                       session)
          switch(
            received_message$type,
            
            ## login messages reactions ####
            login = {
              # if couldn't log in
              if (!received_message$data$success) {
                # check what was the reason: 
                # user doesn't exist:
                if (!received_message$data$username) {
                  # show the modal if configuration allows
                  if (modals_check(private, "login_badId")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nfound_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nfound_1")),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nforun_2")),
                                  footer = modalButton("OK")))
                  }
                } else {
                  # if the password is wrong
                  if (modals_check(private, "login_badPass")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_wrong_pass_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_wrong_pass_b")),
                                  footer = modalButton("OK")))
                  }
                }
              } else {
                # if login is successful
                if (modals_check(private, "login_success")) {
                  showModal(
                    modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_succ_t"),
                                p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_succ_b")),
                                footer = modalButton("OK")))
                }
                
                # change the log-in state
                self$is_logged(TRUE)
                self$user_id(received_message$data$user_id)
                self$user_mail(received_message$data$user_mail)
                
              }
            },
            
            ## register messages reactions ####
            register = {
              
              # if registration is successful
              if (received_message$data$success) {
                # show modal if enabled
                if (modals_check(private, "register_success")) {
                  showModal(
                    modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_succ_t"),
                                p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_succ_b")),
                                footer = modalButton("OK")))
                }
                
                # send message to the mailConnector
                
                message_to_send <- RegLogConnectorMessage(
                  "register_mail",
                  username = received_message$data$user_id,
                  email = received_message$data$user_mail,
                  app_name = private$app_name,
                  app_address = private$app_address
                )
                
                self$mailConnector$listener(message_to_send)
                save_to_logs(message_to_send,
                             "sent",
                             self,
                             session)
                
              } else {
                # if registering failed
                
                if (!received_message$data$username) {
                  if (modals_check(private, "register_existingID")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err1_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err1_b")),
                                  footer = modalButton("OK"))
                    )
                  }
                } else if (!received_message$data$email) {
                  if (modals_check(private, "register_existingMail")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err1m_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err1m_b")),
                                  footer = modalButton("OK"))
                    )
                  }
                }
              }
            },
            
            ## data edit messages reactions ####
            credsEdit = {

              # if data change is successful              
              if (received_message$data$success) {
                if (modals_check(private, "credsEdit_success")) {
                  showModal(
                    modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "credEdit_mod_succ_t"),
                                p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "credEdit_mod_succ_b")),
                                footer = modalButton("OK")))
                }
                if (!is.null(received_message$data$new_user_id)) {
                  self$user_id(received_message$data$new_user_id)
                }
                if (!is.null(received_message$data$new_user_mail)) {
                  self$user_mail(received_message$data$new_user_mail)
                }
                # if there were any conflicts
              } else {
                if (isFALSE(received_message$data$username)) {
                  if (modals_check(private, "credsEdit_badId")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nfound_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nfound_1")),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "id_nforun_2")),
                                  footer = modalButton("OK")))
                  }
                } else if (isFALSE(received_message$data$password)) {
                  if (modals_check(private, "credsEdit_badPass")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_wrong_pass_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "login_wrong_pass_b")),
                                  footer = modalButton("OK")))
                  }
                } else if (isFALSE(received_message$data$new_username)) {
                  if (modals_check(private, "credsEdit_existingID")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err1_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err1_b")),
                                  footer = modalButton("OK"))
                    )
                  }
                } else if (isFALSE(received_message$data$new_email)) {
                  if (modals_check(private, "credsEdit_existingMail")) {
                    showModal(
                      modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err1m_t"),
                                  p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err1m_b")),
                                  footer = modalButton("OK"))
                    )
                  }
                }
                
                
                
              }
              
              # expose the message
              self$message(received_message)
              
              
            },
            
            ## reset password messages reactions ####
            
            resetpass = {
              
              
              
            }
            
          )
          
          #expose the message to the outside
          self$message(received_message)
          
        })
      })
      
      # observe changes in mailConnector ####
      
      observe({
        
        # safety check - for the dbConnector to not be NULL
        req(!is.null(self$mailConnector))
        
        # receive the message
        received_message <- self$mailConnector$message()
        req(class(received_message) == "RegLogConnectorMessage")
        # intercept only messages with "mail" suffix in `type`
        req(grepl(x = received_message$type, pattern = "_mail$"))
        
        isolate({
          # save message to logs
          save_to_logs(received_message,
                       "received",
                       self,
                       session)
          
          #expose the message to the outside
          self$message(received_message)
          
        })
      })
    })
}