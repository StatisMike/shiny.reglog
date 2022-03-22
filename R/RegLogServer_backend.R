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
      self$mail_message <- reactiveVal()
      self$is_logged <- reactiveVal(FALSE)
      self$user_id <- reactiveVal(uuid::UUIDgenerate())
      self$user_mail <- reactiveVal()
      self$account_id <- reactiveVal()
      private$listener <- reactiveVal()
      
      # get app_address if not specified
      observe(
        if (is.null(private$app_address)) {
          private$app_address <- get_url_shiny(session = session)
        }
      )
      
      # login UI reactions ####
      
      observeEvent(input$login_button, {
        
        # check if the inputs are filled
        if (!all(isTruthy(input$login_user_id), isTruthy(input$password_login))) {
          
          modals_check_n_show(private = private,
                              modalname = "login_noInput")
          
          message_to_show <- RegLogConnectorMessage(
            type = "login_front",
            success = FALSE,
            input_provided = FALSE
          )
          
          # show message and save to logs if enabled
          self$message(message_to_show)
          save_to_logs(message_to_show, "shown", self, session)
          
        } else {
          
          on.exit(blank_textInputs(inputs = c("login_user_id", "password_login"),
                                    session = session))
          
          shinyjs::runjs("$('.reglog_bttn').attr('disabled', true)")
          
          # send message
          message_to_send <- RegLogConnectorMessage(
            type = "login",
            username = trimws(input$login_user_id, "both"),
            password = trimws(input$password_login, "both")
          )
          
          self$dbConnector$listener(message_to_send)
          
          # save into logs
          save_to_logs(message_to_send, "sent", self, session)
          
        }
      })
      
      # register UI reactions ####
      
      observeEvent(input$register_bttn, {
        
        # check if the inputs are filled
        if (!all(isTruthy(input$register_user_ID), isTruthy(input$register_email),
                 isTruthy(input$register_pass1), isTruthy(input$register_pass2))) {
          
          modals_check_n_show(private = private,
                              modalname = "register_noInput")
          
          # parse message to show
          message_to_show <- RegLogConnectorMessage(
            "register_front",
            success = FALSE,
            input_provided = FALSE
          )
          
          # show message and save to logs if enabled
          self$message(message_to_show)
          save_to_logs(message_to_show, "shown", self, session)
          
        } else {
          
          on.exit(blank_textInputs(inputs = c("register_pass1", "register_pass2"),
                                    session = session))
          
          # check validity of inputs
          
          if (!check_user_login(input$register_user_ID) || !check_user_mail(input$register_email) ||
              !check_user_pass(input$register_pass1) || (input$register_pass1 != input$register_pass2)) {
            
            # parse message to show
            message_to_show <- RegLogConnectorMessage(
              "register_front",
              success = FALSE,
              input_provided = TRUE,
              valid_id = check_user_login(input$register_user_ID),
              valid_email = check_user_mail(input$register_email),
              valid_pass = check_user_pass(input$register_pass1),
              identical_pass = input$register_pass1 == input$register_pass2
            )
            
            # show modalDialog
            modals_check_n_show(
              private = private,
              modalname = if (!message_to_show$data$valid_id) "register_nonValidId"
                     else if (!message_to_show$data$valid_email) "register_nonValidEmail"
                     else if (!message_to_show$data$valid_pass) "register_nonValidPass"
                     else if (!message_to_show$data$identical_pass) "register_notIdenticalPass"
              )
            
            # show message and save to logs if enabled
            self$message(message_to_show)
            save_to_logs(message_to_show, "shown", self, session)
            
          } else {
            
            on.exit(blank_textInputs(inputs = c("register_user_ID", "register_email"),
                                      session = session), add = T)
            
            message_to_send <- RegLogConnectorMessage(
              type = "register",
              username = trimws(input$register_user_ID, "both"),
              password = trimws(input$register_pass1, "both"),
              email = trimws(input$register_email, "both")
            )
            
            shinyjs::runjs("$('.reglog_bttn').attr('disabled', true)")
            
            self$dbConnector$listener(message_to_send)
            
            # save into logs
            save_to_logs(message_to_send, "sent", self, session)
          }
        }
      })
      
      # creds edit password change ####
      observeEvent(input$cred_edit_pass_change, {
        
        on.exit({
          self$message(message_to_show)
          save_to_logs(message_to_show,
                       "shown",
                       self,
                       session)
        })
        
        # check if the user is logged in currently
        if (!isTRUE(self$is_logged())) {
          
          message_to_show <- RegLogConnectorMessage(
            "credsEdit_front",
            success = FALSE,
            user_logged = FALSE,
            change = "other"
          )
          
          modals_check_n_show(private,
                              modalname = "credsEdit_notLogged")
          blank_textInputs(c("cred_edit_old_pass", 
                             "cred_edit_new_pass1", "cred_edit_new_pass2"),
                           session = session)
          
          
          # check if the inputs are filled
        } else if (!all(isTruthy(input$cred_edit_old_pass),
                 isTruthy(input$cred_edit_new_pass1), isTruthy(input$cred_edit_new_pass2))) {
          
          message_to_show <- RegLogConnectorMessage(
            type = "credsEdit_front",
            success = FALSE,
            user_logged = TRUE,
            input_provided = FALSE,
            change = "pass"
          )
          
          modals_check_n_show(private = private,
                              modalname = "credsEdit_noInput_pass")
          
          # check validity of inputs
        } else if (!check_user_pass(input$cred_edit_new_pass1) || 
                   input$cred_edit_new_pass1 != input$cred_edit_new_pass2) {
          
          message_to_show <- RegLogConnectorMessage(
            type = "credsEdit_front",
            success = FALSE,
            user_logged = TRUE,
            input_provided = TRUE,
            change = "pass",
            valid_pass = check_user_pass(input$cred_edit_new_pass1),
            identical_pass = input$cred_edit_new_pass1 == input$cred_edit_new_pass2
          )
          
          blank_textInputs(c("cred_edit_new_pass1", "cred_edit_new_pass2"),
                            session = session)
          
          modals_check_n_show(
            private = private,
            modalname = if (!message_to_show$data$valid_pass) "credsEdit_nonValidPass"
                   else if (!message_to_show$data$identical_pass) "credsEdit_notIdenticalPass"
          )
          # if everything is OK - send the message
        } else {
          
          on.exit({
            self$dbConnector$listener(message_to_send)
            save_to_logs(message_to_send, "sent", self, session)
          })
          
          blank_textInputs(c("cred_edit_new_pass1", "cred_edit_new_pass2", 
                              "cred_edit_old_pass"), 
                            session = session)
          
          message_to_send <- RegLogConnectorMessage(
            type = "credsEdit",
            account_id = self$account_id(),
            password = input$cred_edit_old_pass,
            new_password = input$cred_edit_new_pass1
          )
          
          shinyjs::runjs("$('.reglog_bttn').attr('disabled', true)")
        }
      })
      
      # creds edit credentials change ####
      
      observeEvent(input$cred_edit_other_change, {
        
        on.exit({
          self$message(message_to_show)
          save_to_logs(message_to_show, "shown", self, session)
        })
        
        # check if the user is logged in currently
        if (!isTRUE(self$is_logged())) {
          
          message_to_show <- RegLogConnectorMessage(
            "credsEdit_front",
            success = FALSE,
            user_logged = FALSE,
            change = "other"
          )
          
          modals_check_n_show(private,
                              modalname = "credsEdit_notLogged")
          blank_textInputs(c("cred_edit_old_pass", 
                             "cred_edit_new_ID", "cred_edit_new_mail"),
                           session = session)
          
          
          # check if the inputs are filled
        } else if (!isTruthy(input$cred_edit_old_pass) &&
            !any(isTruthy(input$cred_edit_new_ID), isTruthy(input$cred_edit_new_mail))) {
          
          message_to_show <- RegLogConnectorMessage(
            "credsEdit_front",
            success = FALSE,
            user_logged = TRUE,
            input_provided = FALSE,
            change = "other"
          )
          
          modals_check_n_show(private,
                              modalname = "credsEdit_noInput_other")
          
          # check if the inputs are valid
        } else if (isTruthy(input$cred_edit_new_ID) && !check_user_login(input$cred_edit_new_ID) ||
                   isTruthy(input$cred_edit_new_mail) && !check_user_mail(input$cred_edit_new_mail)) {
          
          message_to_show <- RegLogConnectorMessage(
            "credsEdit_front",
            success = FALSE,
            user_logged = TRUE,
            input_provided = TRUE,
            change = "other",
            valid_id = if (isTruthy(input$cred_edit_new_ID)) check_user_login(input$cred_edit_new_ID),
            valid_email = if (isTruthy(input$cred_edit_new_mail)) check_user_mail(input$cred_edit_new_mail)
          )
          
          modals_check_n_show(
            private = private,
            modalname = if (isFALSE(message_to_show$data$valid_id)) "credsEdit_nonValidId"
                   else if (isFALSE(message_to_show$data$valid_email)) "credsEdit_nonValidEmail")
          
          blank_textInputs(c("cred_edit_old_pass", 
                              "cred_edit_new_ID", "cred_edit_new_mail"),
                            session = session)
          
        } else {
          # if everything is all right, send message to dbConnector
          
          on.exit({
            self$dbConnector$listener(message_to_send)
            save_to_logs(message_to_send, "sent", self, session)
          })
          
          message_to_send <- RegLogConnectorMessage(
            "credsEdit",
            account_id = self$account_id(),
            password = input$cred_edit_old_pass,
            new_username = if (isTruthy(input$cred_edit_new_ID)) input$cred_edit_new_ID,
            new_email = if (isTruthy(input$cred_edit_new_mail)) input$cred_edit_new_mail
          )
          
          blank_textInputs(c("cred_edit_old_pass", 
                              "cred_edit_new_ID", "cred_edit_new_mail"),
                            session = session)
          
          shinyjs::runjs("$('.reglog_bttn').attr('disabled', true)")
          
        }
      })
      
      # resetPass generate observer ####
      observeEvent(input$reset_send, {
        
        if (!isTruthy(input$reset_user_ID)) {
          
          modals_check_n_show(private, "resetPass_noInput_generate")
          
          message_to_show <- RegLogConnectorMessage(
            "resetPass_front",
            success = FALSE,
            step = "generate",
            input_provided = FALSE
          )
          
          self$message(message_to_show)
          save_to_logs(message_to_show, "shown", self, session)
          
        } else {
          message_to_send <- RegLogConnectorMessage(
            "resetPass_generate",
            username = input$reset_user_ID
          )
          
          shinyjs::runjs("$('.reglog_bttn').attr('disabled', true)") 
          
          blank_textInputs("reset_user_ID", session = session)
          
          self$dbConnector$listener(message_to_send)
          save_to_logs(message_to_send, "sent", self, session)
        }
      })
      
      # resetPass confirm observer ####
      observeEvent(input$reset_confirm_bttn, {
        
        on.exit({
          self$message(message_to_show)
          save_to_logs(message_to_show, "shown", self, session)
        })
        
        # check if the inputs are filled
        if (!all(isTruthy(input$reset_user_ID), isTruthy(input$reset_code),
                 isTruthy(input$reset_pass1), isTruthy(input$reset_pass2))) {
          
          modals_check_n_show(private, "resetPass_noInput_confirm")
          message_to_show <- RegLogConnectorMessage(
            "resetPass_front",
            success = FALSE,
            step = "confirm",
            input_provided = FALSE
          )
          
        } else if (!check_user_pass(input$reset_pass1) || input$reset_pass1 != input$reset_pass2) {
          
          modals_check_n_show(
            private = private, 
            modalname = if (!check_user_pass(input$reset_pass1)) "resetPass_nonValidPass"
                   else if (input$reset_pass1 != input$reset_pass2) "resetPass_notIdenticalPass"
            )
          
          message_to_show <- RegLogConnectorMessage(
            "resetPass_front",
            success = FALSE,
            step = "confirm",
            input_provided = TRUE,
            valid_pass = check_user_pass(input$reset_pass1),
            identical_pass = input$reset_pass1 == input$reset_pass2
          )
          
          blank_textInputs(c("reset_pass1", "reset_pass2"), 
                            session = session)
          
        } else {
          
          on.exit({
            self$dbConnector$listener(message_to_send)
            save_to_logs(message_to_send, "sent", self, session)
          })
          
          message_to_send <- RegLogConnectorMessage(
            "resetPass_confirm",
            username = input$reset_user_ID,
            reset_code = input$reset_code,
            password = input$reset_pass1
          )
          
          blank_textInputs(c("reset_user_ID", "reset_code", 
                              "reset_pass1", "reset_pass2"), 
                            session = session)
          
          shinyjs::runjs("$('.reglog_bttn').attr('disabled', true)")
        }
      })
    }
  )
}