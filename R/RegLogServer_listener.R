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
              
              if (received_message$data$success) {
                
                modals_check_n_show(private = private,
                                    modalname = "logout_success")
                # clear user data
                self$is_logged(FALSE)
                self$user_id(uuid:UUIDgenerate())
                self$user_mail("")
                
              } else {
                
                modals_check_n_show(private = private,
                                    modalname = "logout_notLogIn")
                
              }
            }
          )
        })
        #expose the message to the outside
        self$message(received_message)
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
                  modals_check_n_show(private = private,
                                      modalname = "login_badId")
                } else {
                  # if the password is wrong
                  modals_check_n_show(private = private,
                                      modalname = "login_badPass")
                }
              } else {
                # if login is successful
                shinyjs::runjs("$('.reglog_bttn').attr('disabled', false)")
                
                modals_check_n_show(private = private,
                                    modalname = "login_success")
                
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
                
                shinyjs::runjs("$('.reglog_bttn').attr('disabled', false)")
                
                # show modal if enabled
                modals_check_n_show(private, "register_success")
                
                # send message to the mailConnector
                message_to_send <- RegLogConnectorMessage(
                  "reglog_mail",
                  process = "register",
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
                
                modals_check_n_show(
                  private = private,
                  modalname = if (isFALSE(received_message$data$username)) "register_existingId"
                         else if (isFALSE(received_message$data$email)) "register_existingEmail"
                )
              }
            },
            
            ## data edit messages reactions ####
            credsEdit = {

              # if data change is successful
              if (received_message$data$success) {
                
                shinyjs::runjs("$('.reglog_bttn').attr('disabled', false)")
                
                modals_check_n_show(private,
                                    "credsEdit_success")
                
                if (!is.null(received_message$data$new_user_id)) {
                  self$user_id(received_message$data$new_user_id)
                }
                if (!is.null(received_message$data$new_user_mail)) {
                  self$user_mail(received_message$data$new_user_mail)
                }
                
                # send message to the mailConnector
                message_to_send <- RegLogConnectorMessage(
                  "reglog_mail",
                  process = "credsEdit",
                  username = self$user_id(),
                  email = self$user_mail(),
                  app_name = private$app_name,
                  app_address = private$app_address
                )
                
                self$mailConnector$listener(message_to_send)
                save_to_logs(message_to_send,
                             "sent",
                             self,
                             session)
                
                # if there were any conflicts
              } else {
                modals_check_n_show(
                  private = private,
                  modalname = if (isFALSE(received_message$data$username)) "credsEdit_badId"
                         else if (isFALSE(received_message$data$password)) "credsEdit_badPass"
                         else if (isFALSE(received_message$data$new_username)) "credsEdit_existingId"
                         else if (isFALSE(received_message$data$new_email)) "credsEdit_existingEmail"
                  )
              }
            },
            
            # reset password generation messages reactions ####
            
            resetPass_generate = {
              
              # if generation were successful
              if (received_message$data$success) {
                
                shinyjs::runjs("$('.reglog_bttn').attr('disabled', false)")
                
                modals_check_n_show(private, "resetPass_codeGenerated")

                # send message to the mailConnector
                message_to_send <- RegLogConnectorMessage(
                  "reglog_mail",
                  process = "resetPass",
                  username = received_message$data$user_id,
                  email = received_message$data$user_mail,
                  app_name = private$app_name,
                  app_address = private$app_address,
                  reset_code = received_message$data$reset_code
                )
                
                self$mailConnector$listener(message_to_send)
                save_to_logs(message_to_send,
                             "sent",
                             self,
                             session)
                
              } else {
                #if not successful
                modals_check_n_show(private, "resetPass_badId")
              }
            },
            
            # reset password confirmation messages reactions ####

            resetPass_confirm = {
              # if reset code was valid
              if (received_message$data$success) {
                
                shinyjs::runjs("$('.reglog_bttn').attr('disabled', false)")
                
                modals_check_n_show(private, "resetPass_success")

              } else {
                #if not successful
                modals_check_n_show(
                  private = private,
                  modalname = if (isFALSE(received_message$data$username)) "resetPass_badId"
                         else if (isFALSE(received_message$data$code_valid)) "resetPass_nonValidCode"
                )
              }
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
        
        isolate({
          # save message to logs
          save_to_logs(received_message,
                       "received",
                       self,
                       session)
          
          #expose the message to the outside
          self$mail_message(received_message)
          
        })
      })
    })
}