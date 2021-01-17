#### UI module for login window ####

#' Shiny UI module for login box
#'
#' This function creates a UI div() element containing informations and input necessary for user to log-in.
#' As it outputs a div() element, you can put it inside container of your choosing (be it some tabItem, fluidPage, fluidRow etc.)
#'
#' It need to be used in conjuction with \code{login_server()} function and is suggested to be used alongside \code{password_reset_UI()} and \code{register_UI()} for full potential.
#'
#' @param id the id of the module. Defaults to "login_system" for all of the modules contained within the package. If you plan to use serveral login systems inside your app or for any other reason need to change it, remember to keep consistent id for all elements of module.
#' @param lang specifies the app used language. Defaults to "eng" for English. Package also supports "pl" for Polish
#'
#' @return NONE
#'
#' @seealso login_server() for more details and example
#'
#' @export
#'

login_UI <- function(id = "login_system",
                     lang = "eng") {

  ns <- NS(id)

  div(h1("Login"),
      textInput(ns("login_user_id"),
                case_when(lang == "eng" ~ "User ID",
                          lang == "pl" ~ "Nazwa użytkownika")
      ),
      passwordInput(ns("password_login"),
                    case_when(lang == "eng" ~ "Password",
                              lang == "pl"~ "Hasło")),
      actionButton(ns("login_button"),
                   case_when(lang == "eng" ~ "Log-in",
                             lang == "pl" ~ "Zaloguj")))
}

#### UI module for password reset ####

#' Shiny UI module for password reset
#'
#' This function creates a UI div() element containing informations and input necessary for user to reset password.
#' As it outputs a div() element, you can put it inside container of your choosing (be it some tabItem, fluidPage, fluidRow etc.). It is important to mention that password reset procedure invokes modalDialog(), so it should be avoided to contain this function inside one.
#'
#' It need to be used in conjuction with \code{login_server()} function and is suggested to be used alongside \code{login_UI()} and \code{register_UI()} for full potential.
#'
#' @param id the id of the module. Defaults to "login_system" for all of the modules contained within the package. If you plan to use serveral login systems inside your app or for any other reason need to change it, remember to keep consistent id for all elements of module.
#' @param lang specifies the app used language. Defaults to "eng" for English. Package also supports "pl" for Polish
#'
#' @return NONE
#'
#' @seealso login_server() for more details and example
#'
#' @export

password_reset_UI <- function(id = "login_system",
                              lang = "eng") {

  ns <- NS(id)

  div(
    h1(case_when(lang == "eng" ~ "Reset you password",
                 lang == "pl" ~ "Resetowanie hasła")),
    p(case_when(lang == "eng" ~ "To reset your password, type in your user ID and press the 'Send code' button. The code to reset your password will be send to e-mail that you provided during registration. Message should arrive in few minutes.",
                lang == "pl" ~ "Aby zresetować hasło, wprowadź swoją nazwę użytkownika i wciśnij przycisk 'Wyślij kod'. Kod do zresetowania hasła zostanie wysłany na e-mail podany podczas rejestracji. Wiadomość powinna dotrzeć w ciągu kilku minut")),
    textInput(ns("resetpass_user_ID"),
              case_when(lang == "eng" ~ "User ID",
                        lang == "pl" ~ "Nazwa użytkownika")),
    actionButton(ns("resetpass_send"),
                 case_when(lang == "eng" ~ "Send code",
                           lang == "pl" ~ "Wyślij kod")),
    p(case_when(lang == "eng" ~ "After getting the e-mail type the received code in the box below and press the 'Confirm code' button. The code will be active for half an hour.",
                lang == "pl" ~ "Po otrzymaniu wiadomości wprowadź otrzymany kod w pole poniżej i wciśnij przycisk 'Potwierdź kod'. Kod będzie aktywny przez pół godziny.")),
    textInput(ns("resetpass_code"),
              case_when(lang == "eng" ~ "Received code",
                        lang == "pl" ~ "Otrzymany kod")),
    actionButton(ns("resetpass_code_bttn"),
                 case_when(lang == "eng" ~ "Confirm code",
                           lang == "pl" ~ "Potwierdź kod"))
  )

}

#### UI module for registration ####

#' Shiny UI module for registration box
#'
#' This function creates a UI div() element containing informations and input necessary for user to register new account.
#' As it outputs a div() element, you can put it inside container of your choosing (be it some tabItem, fluidPage, fluidRow etc.)
#'
#' It need to be used in conjuction with \code{login_server()} function and is suggested to be used alongside \code{login_UI()} and \code{password_reset_UI()} for full potential.
#'
#' @param id the id of the module. Defaults to "login_system" for all of the modules contained within the package. If you plan to use serveral login systems inside your app or for any other reason need to change it, remember to keep consistent id for all elements of module.
#' @param lang specifies the app used language. Defaults to "eng" for English. Package also supports "pl" for Polish
#'
#' @return NONE
#'
#' @seealso login_server() for more details and example
#'
#' @export

register_UI <- function(id = "login_system",
                        lang = "eng"){

  ns <- NS(id)

  div(
    h1(case_when(lang == "eng" ~ "Registration form",
                 lang == "pl" ~ "Formularz rejestracyjny")),
    p(case_when(lang == "eng" ~ "In the form below you can register a new account. Choose an user ID, provide a valid e-mail adress and choose a password for your account.",
                lang == "pl" ~ "W poniższym formularzu można zarejetrować nowe konto. Wybierz nazwę użytkownika, podaj poprawny adres e-mail i wybierz hasło dla swojego konta"),
      tags$ul(tags$li(case_when(lang == "eng" ~ "User ID and password should constist of 8~20 alphanumeric characters",
                                lang == "pl" ~ "Nazwa użytkownika i hasło powinny składać się z 8~20 liter i/lub cyfr")),
              tags$li(case_when(lang == "eng" ~ "You should have access to provided e-mail address. After registration you will receive confirmation e-mail. Moreover, if you ever forget your password you can reset it with your e-mail.",
                                lang == "pl" ~ "Podany adres e-mail powinien dla ciebie dostępny. Po rejestracji otrzymasz wiadomość potwierdzającą. Co więcej, jeżeli kiedykolwiek zapomnisz swojego hasła, możesz je zresetować poprzez e-mail.")))),
    textInput(ns("register_user_ID"), case_when(lang == "eng" ~ "User ID",
                                                lang == "pl" ~ "Nazwa użytkownika")),
    textInput(ns("register_email"), case_when(lang == "eng" ~ "E-mail address",
                                              lang == "pl" ~ "Adres e-mail")),
    passwordInput(ns("register_pass1"), case_when(lang == "eng" ~ "Your password",
                                                  lang == "pl" ~ "Twoje hasło")),
    passwordInput(ns("register_pass2"), case_when(lang == "eng" ~ "Repeat your password",
                                                  lang == "pl" ~ "Powtórz swoje hasło")),
    actionButton(ns("register_bttn"), case_when(lang == "eng" ~ "Register",
                                                lang == "pl" ~ "Zarejestruj"))

  )

}
