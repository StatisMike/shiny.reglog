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
      
      # create tagList for login ####
      observe(
        self$UI_list_login <- list(
          title = h1("Login"),
          id_input = textInput(
            session$ns("login_user_id"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="user_id")
          ),
          pass_input = passwordInput(
            session$ns("password_login"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="password")
          ),
          confirm_button = actionButton(
            session$ns("login_button"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="login_bttn")
          )
        )
      )
      
      # render UI for login and ease of usage ####
      output$login_ui <- renderUI(
        tagList(self$UI_list_login)
      )
      
      # create tagList for registration ####
      observe(
        self$UI_list_register <- list(
          title = h1(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_ui_1")),
          description = p(
            reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_ui_2"),
            tags$ul(tags$li(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_ui_3")),
                    tags$li(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_ui_4")))),
          id_input = textInput(
            session$ns("register_user_ID"), 
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="user_id")
          ),
          mail_input = textInput(
            session$ns("register_email"), 
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="email")
          ),
          pass1_input = passwordInput(
            session$ns("register_pass1"), 
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="password")
          ),
          pass2_input = passwordInput(
            session$ns("register_pass2"), 
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="password_rep")
          ),
          confirm_button = actionButton(
            session$ns("register_bttn"), 
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="register_bttn")
          )
        )
      )
      
      # render UI for registration and ease of use ####
      output$register_ui <- renderUI(
        tagList(self$UI_list_register)
      )
      
      # create tagList for credentials edit ####      
      observe(
        self$UI_list_credsEdit <- list(
          title = h1(
            reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_ui_h1")),
          h_current = h2(
            reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_ui_h2_old")),
          desc_current = p(
            reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_ui_p_old")),
          id_current_input = textInput(
            session$ns("cred_edit_old_ID"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "user_id")),
          pass_current_input = passwordInput(
            session$ns("cred_edit_old_pass"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "password")),
          hr1 = tags$hr(),
          h_pass = h2(reglog_txt(
            lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_ui_h2_pass_change")),
          desc_pass = p(
            reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_ui_p_pass_change")),
          newpass1_input = passwordInput(
            session$ns("cred_edit_new_pass1"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "password")),
          newpass2_input = passwordInput(
            session$ns("cred_edit_new_pass2"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "password_rep")),
          new_pass_confirm_button = actionButton(
            session$ns("cred_edit_pass_change"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_pass_change_bttn")),
          hr2 = tags$hr(),
          h_creds = h2(
            reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_ui_h2_other_change")),
          desc_creds = p(
            reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_ui_p_other_change")),
          new_id_input = textInput(
            session$ns("cred_edit_new_ID"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "user_id")),
          new_mail_input = textInput(
            session$ns("cred_edit_new_mail"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "email")),
          new_creds_confirm_button = actionButton(
            session$ns("cred_edit_other_change"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "cred_edit_other_change_bttn"))
        )
      )
      
      # render UI for credentials edit ####
      output$creds_edit_ui <- renderUI(
        tagList(self$UI_list_credsEdit)
      )
      
      # create tagList for reset password procedure ####
      
      observe(
        self$UI_list_resetPass <- list(
          title = h1(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="reset_ui_1")),
          desc1 = p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="reset_ui_2")),
          user_ID = textInput(
            session$ns("reset_user_ID"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="user_id")
          ),
          send_code_bttn = actionButton(
            session$ns("reset_send"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="reset_bttn_1")),
          desc2 = p(reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="reset_ui_3")),
          reset_code = textInput(
            session$ns("reset_code"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="reset_ui_4")),
          desc_pass = p(
            reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "reset_ui_p_pass_change")),
          newpass1_input = passwordInput(
            session$ns("reset_pass1"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "password")),
          newpass2_input = passwordInput(
            session$ns("reset_pass2"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x = "password_rep")),
          confirm_code_bttn = actionButton(
            session$ns("reset_confirm_bttn"),
            label = reglog_txt(lang = private$lang, custom_txts = private$custom_txts, x ="reset_bttn_2")
          )
        )
      )
      
      # render UI for reset password procedure ####
      output$reset_pass_ui <- renderUI(
        tagList(self$UI_list_resetPass)
      )
    }
  )
}