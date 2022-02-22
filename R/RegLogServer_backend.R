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
      self$user_id <- reactiveVal(uuid::UUIDgenerate())
      self$user_mail <- reactiveVal("")
      private$listener <- reactiveVal()
      
      observe(
        if (is.null(private$app_address)) {
          private$app_address <- get_url_shiny(session = session)
        }
      )
      
      # login UI reactions ####
      
      observeEvent(input$login_button, {
        
        # check if the inputs are filled
        req(input$login_user_id, input$password_login) 
        
        on.exit(.blank_textInputs(inputs = c("login_user_id", "password_login"),
                                  session = session))
        
        # send message
        message_to_send <- RegLogConnectorMessage(
          type = "login",
          username = input$login_user_id,
          password = input$password_login
        )
        
        self$dbConnector$listener(message_to_send)
        
        # save into logs
        save_to_logs(message_to_send,
                     "sent",
                     self,
                     session)
      })
      
      # register UI reactions ####
      
      observeEvent(input$register_bttn, {
        
        # check if the inputs are filled
        req(input$register_user_ID, input$register_email, input$register_pass1, input$register_pass2)
        
        on.exit(.blank_textInputs(inputs = c("register_pass1", "register_pass2"),
                                  session = session))
        
        # check validity of login
        if (!check_user_login(input$register_user_ID)) {
          
          if (modals_check(private, "register_nonValidID")) {
          showModal(
            modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err2_t"),
                        p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err2_b")),
                        footer = modalButton("OK")))
          }
          
          # parse message to show back in the self$message
          message_to_show <- RegLogConnectorMessage(
            "register_front",
            success = F, valid_id = F, valid_email = F, valid_pass = F, identical_pass = F 
          )
          
          self$message(message_to_show)
          save_to_logs(message_to_show,
                       "shown",
                       self,
                       session)
          
          # check validity of email
        } else if (!check_user_mail(input$register_email)) {
          
          if (modals_check(private, "register_nonValidEmail")) {
          showModal(
            modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err3_t"),
                        p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err3_b")),
                        footer = modalButton("OK")))
          }
          
          # parse message to show back in the self$message
          message_to_show <- RegLogConnectorMessage(
            "register_front",
            success = F, valid_id = T, valid_email = F, valid_pass = F, identical_pass = F 
          )
          
          self$message(message_to_show)
          save_to_logs(message_to_show,
                       "shown",
                       self,
                       session)
          
          # check validity of password
        } else if (!check_user_pass(input$register_pass1)) {
          
          if (modals_check(private, "register_nonValidPass")) {
          showModal(
            modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err4_t"),
                        p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err4_b")),
                        footer = modalButton("OK")))
          }
          
          # parse message to show back in the self$message
          message_to_show <- RegLogConnectorMessage(
            "register_front",
            success = F, valid_id = T, valid_email = T, valid_pass = F, identical_pass = F 
          )
          
          self$message(message_to_show)
          save_to_logs(message_to_show,
                       "shown",
                       self,
                       session)
          
          # check if passwords are the same
        } else if (input$register_pass1 != input$register_pass2) {
          
          if (modals_check(private, "register_notIndenticalPass")) {
          showModal(
            modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err5_t"),
                        p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err5_b")),
                        footer = modalButton("OK")))
          }
          
          # parse message to show back in the self$message
          message_to_show <- RegLogConnectorMessage(
            "register_front",
            success = F, valid_id = T, valid_email = T, valid_pass = T, identical_pass = F 
          )
          
          self$message(message_to_show)
          save_to_logs(message_to_show,
                       "shown",
                       self,
                       session)
          
          # if everything is OK - send the message
        } else {
          
          message_to_send <- RegLogConnectorMessage(
            type = "register",
            username = input$register_user_ID,
            password = input$register_pass1,
            email = input$register_email,
            logcontent = paste0(input$register_user_ID, "/", input$register_email)
          )
          
          self$dbConnector$listener(message_to_send)
          
          # save into logs
          save_to_logs(message_to_send,
                       "sent",
                       self,
                       session)
        }
      })
      
      # creds edit password change ####
      observeEvent(input$cred_edit_pass_change) {
        
        # check if the inputs are filled
        req(input$cred_edit_old_ID, input$cred_edit_old_pass, 
            input$cred_edit_new_pass1, input$cred_edit_new_pass2)
        
        if (!check_user_pass(input$cred_edit_new_pass1)) {
          
          if (modals_check(private, "credEdit_nonValidPass")) {
            showModal(
              modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err4_t"),
                          p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err4_b")),
                          footer = modalButton("OK")))
          }
          
          # parse message to show back in the self$message
          message_to_show <- RegLogConnectorMessage(
            "credEdit_front",
            success = F, valid_pass = F, identical_pass = F 
          )
          
          self$message(message_to_show)
          save_to_logs(message_to_show,
                       "shown",
                       self,
                       session)
          
          # check if passwords are the same
        } else if (input$cred_edit_new_pass1 != input$cred_edit_new_pass2) {
          
          if (modals_check(private, "credEdit_notIndenticalPass")) {
            showModal(
              modalDialog(title = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err5_t"),
                          p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reg_mod_err5_b")),
                          footer = modalButton("OK")))
          }
          
          # parse message to show back in the self$message
          message_to_show <- RegLogConnectorMessage(
            "credEdit_front",
            success = F, valid_pass = T, identical_pass = F 
          )
          
          self$message(message_to_show)
          save_to_logs(message_to_show,
                       "shown",
                       self,
                       session)
          
          # if everything is OK - send the message
        } else {
          
          message_to_send <- RegLogConnectorMessage(
            type = "credEdit",
            username = input$cred_edit_old_ID,
            password = input$cred_edit_old_pass,
            new_password = input$cred_edit_new_pass1,
            logcontent = paste(input$cred_edit_old_ID, "password")
          )
          
          self$dbConnector$listener(message_to_send)
          
          # save into logs
          save_to_logs(message_to_send,
                       "sent",
                       self,
                       session)
        }
      }
      
      # creds edit credentials change ####
      
      observeEvent(input$cred_edit_other_change, {
        
        # check if the inputs are filled
        req(input$cred_edit_old_ID, input$cred_edit_old_pass)
        req(isTRUE(nchar(input$cred_edit_new_ID) > 0) || isTRUE(nchar(input$cred_edit_new_mail) > 0))
        
        # create placeholder message to show with success
        message_to_show <- RegLogConnectorMessage(
          "credEdit_front",
          success = T 
        )
        # create message to send
        message_to_send <- RegLogConnectorMessage(
          "credEdit",
          username = input$cred_edit_old_ID,
          password = input$cred_edit_old_pass
        )
        
        ## check if there is an ID to change ####
        if (req(input$cred_edit_new_ID)) {
          
          # if ID is not valid
          if (!check_user_login(input$cred_edit_new_ID)) {
            
            message_to_show$data$success <- FALSE
            message_to_show$data$valid_ID <- FALSE
          } else {
            message_to_show$data$valid_ID <- TRUE
            message_to_send$data$new_username <- input$cred_edit_new_ID
          }
        }

        ## check if there is an email to change ####
        if (req(input$cred_edit_new_mail)) {
          
          # if mail is not valid
          if (!check_user_mail(input$cred_edit_new_mail)) {
            
            message_to_show$data$success <- FALSE
            message_to_show$data$valid_mail <- FALSE
          } else {
            message_to_show$data$valid_mail <- TRUE
            message_to_send$data$new_email <- input$cred_edit_new_mail
          }
        }

        ## if not success, try to show modals ####
        if (!message_to_show$data$success) {
          
          if (isFALSE(message_to_show$data$valid_ID)) {
            if (modals_check(private, "credEdit_nonValidID")) {
              showModal(
                modalDialog(title = reglog_txt(lang = lang, custom_txts = custom_txts, x = "reg_mod_err2_t"),
                            p(reglog_txt(lang = lang, custom_txts = custom_txts, x = "reg_mod_err2_b")),
                            footer = modalButton("OK")))
            } 
          }
          if (isFALSE(message_to_show$data$valid_mail)) {
            if (modals_check(private, "credEdit_nonValidMail")) {
              showModal(
                modalDialog(title = reglog_txt(lang = lang, custom_txts = custom_txts, x = "reg_mod_err3_t"),
                            p(reglog_txt(lang = lang, custom_txts = custom_txts, x = "reg_mod_err3_b")),
                            footer = modalButton("OK")))
            }
          }
          # show message back
          self$message(message_to_show)
          save_to_logs(message_to_show,
                       "shown",
                       self,
                       session)
          
          # is everything is all right, send message
        } else {
          
          message_to_send$logcontent <-
            paste(input$cred_edit_old_ID, "changed:", 
                  paste(c(input$cred_edit_new_username, input$cred_edit_new_mail), collapse = "/"))
          
          self$dbConnector$listener(message_to_send)
          # save into logs
          save_to_logs(message_to_send,
                       "sent",
                       self,
                       session)
        }
      })
    }
  )
}