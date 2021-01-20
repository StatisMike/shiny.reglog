#### helper functions - used to check validity of user ID, password and e-mail ####

# user and password is currently required to consists of 8~20 alphanumeric characters

.check_user_login_pass <- function(x){

  nchar(x) >= 8 & nchar(x) <= 20 & grepl("^[[:alnum:]]+$", x)

}

# mail is currently required: to not contain any spaces, no contain @ character
# and after it some more characters, ending with: ".com", ".org", ".edu", ".gov", ".pl"

.check_user_mail <- function(x) {
  if(grepl("(\\w+ ){0,5}(\\w+)@\\w+\\.(com|org|edu|gov|pl)", x) == TRUE) {

    if(grepl("(\\s+)", x) == TRUE) {FALSE} else {TRUE}

  } else {
    FALSE
  }
}

#### main server module of the package ####
#' @title Login system module
#' @name login_server
#' @description Shiny server module for the login/registration system
#'
#' This function creates a server module to handle other modules of the system: \code{login_UI()}, \code{password_reset_UI()} and \code{register_UI}
#'
#' It uses database contained in googlesheet file on your gdrive to read and write data of the users. You need to create a googlesheet containing at least two sheets with specific columns:
#'
#' user_db with columns named: "timestamp", "user_id", "user_mail" and "user_pass"
#'
#' reset_db with columns named: "timestamp", "user_id", "reset_code"
#'
#' You need to also authorize access to your google drive package outside of the function (fe: using googlesheets4:gs_auth) - in the global.R or in the beginning of app.R file.
#'
#' The module logic creates a reactiveValues() object with loaded database of users and reset codes. It allows to cut the reading from database to only one read per loading of the app - unfortunately it makes the app run slowly if the database of users gets very long.
#'
#' Registration of new account mails the confirmation e-mail to the end user on provided e-mail.
#'
#' Provided e-mail is needed for password reset: 10 digits code is generated and mailed to the user to confirm his or her identity. Reset code remains valid for 24h.
#'
#' Both passwords and reset_codes are hashed with the help of \code{scrypt} package for the extra security.
#'
#' @param id the id of the module. Defaults to "login_system" for all of the modules contained within the package. If you plan to use serveral login systems inside your app or for any other reason need to change it, remember to keep consistent id for all elements of module.
#' @param gsheet_file the ID of your googlesheet holding the database. It is contained within URL adress of your googlesheet
#' @param gmail_user the gmail e-mail address which will be used by application to send automatic messages to your users
#' @param gmail_password the password to gmail account specified above
#' @param appname the character value containing name of your application (it will be used in automatic e-mails for information purposes)
#' @param appaddress the character value containing the web address of your application (it will be used in automatic e-mails for information purposes)
#' @param lang specifies the app used language. Defaults to "eng" for English. Package also supports "pl" for Polish
#'
#' @return reactiveValues() object with three elements:
#' @return active_user, containing either "not_logged" before log-in or row of the user data from database after log-in (timestamp, user_id, user_mail, user_pass)
#' @return user_db, containing the user database loaded from googlesheets
#' @return reset_db, containing the reset code database loaded from googlesheets
#'
#' @seealso [login_UI()] for the login window in UI
#' @seealso [password_reset_UI()] for the password reset window in UI
#' @seealso [register_UI] for the registration window in UI
#'
#' @examples
#' # simple dashboard with login and register functionality
#' # UI containing login_UI, password_reset_UI and register_UI as different tabs
#'
#' UI <- dashboardPage(
#'
#' header = dashboardHeader(title = "Test for login modules"),
#'
#' sidebar = dashboardSidebar(
#'   sidebarMenu(
#'       menuItem("Login", tabName = "login"),
#'           menuItem("Reset password", tabName = "resetpass"),
#'               menuItem("Register", tabName = "register"))
#'               ),
#'
#' body = dashboardBody(
#'    tabItems(
#'        tabItem("login",
#'           fluidPage(login_UI())),
#'        tabItem("resetpass",
#'           fluidPage(password_reset_UI())),
#'        tabItem("register",
#'           fluidPage(register_UI()))
#'              )
#'        )
#'  )
#'
#' # server authorizing gdrive access and including the login_server function
#'
#' server <- function(input, output, session){
#'
#'   googlesheets4::gs4_auth()
#'
#' # the reactive_db is reactiveValues() object to access your data in the app
#'
#'   reactive_db <- login_server(gsheet_file = "your_spreadsheet_id",
#'                               gmail_user = "my_mail@gmail.com",
#'                               gmail_password = "my_password",
#'                               appname = "Login_test",
#'                               appaddress = "logintest.com")
#'
#'  }
#'
#' # shinyApp initialization
#'
#'  shinyApp(ui = UI, server = server)
#' @export
#' @import shiny
NULL
#' @import dplyr
NULL
#' @import emayili
NULL
#' @import googlesheets4
NULL
#' @import scrypt
NULL

login_server <- function(id = "login_system",
                         gsheet_file,
                         gmail_user,
                         gmail_password,
                         appname,
                         appaddress,
                         lang = "eng"){

  moduleServer(
    id,
    function(input, output, session){


      #### first active_user reactiveVal definition ####

      reactive_db <- reactiveValues(
        active_user = dplyr::case_when(lang == "eng" ~ "Not logged",
                                       lang == "pl" ~ "Nie zalogowano"),

        user_db = googlesheets4::read_sheet(ss = gsheet_file,
                                            sheet = "user_db") %>%
          arrange(desc(timestamp)) %>%
          group_by(user_id) %>%
          slice_head() %>%
          ungroup(),

        reset_db = googlesheets4::read_sheet(ss = gsheet_file,
                                             sheet = "reset_db") %>%
          arrange(desc(timestamp)) %>%
          group_by(user_id) %>%
          slice_head() %>%
          ungroup()
      )


      #### login observer ####

      observeEvent(input$login_button, {

        temp_data <- reactive_db$user_db %>%
          filter(user_id == input$login_user_id) %>%
          arrange(desc(timestamp)) %>%
          group_by(user_id) %>%
          slice_head() %>%
          ungroup()

        if(nrow(temp_data) == 0){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "Username not found",
                                                 lang == "pl" ~ "Nie znaleziono użytkownika"),
                        p(dplyr::case_when(lang == "eng" ~ "If the account was registered before, please check if user ID was typed correctly.",
                                           lang == "pl" ~ "Jeżeli konto zostało założone, prosze sprawdzić poprawność wprowadzonej nazwy użytkownika")),
                        p(dplyr::case_when(lang == "eng" ~ "If you haven't registered yet, please register new account.",
                                           lang == "pl" ~ "Jeżeli jeszcze nie utworzono konta, proszę się zarejestrować.")),
                        footer = modalButton("OK"))
          )

        } else if(scrypt::verifyPassword(as.character(temp_data$user_pass[1]),
                                         input$password_login) == F){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "Wrong password",
                                                 lang == "pl" ~ "Nieprawidłowe hasło"),
                        p(dplyr::case_when(lang == "eng" ~ "Typed password doesn't match one in our database. Try again or reset the password.",
                                           lang == "pl" ~ "Wprowadzone hasło jest inne niż powiązane z nazwą użytkownika. Spróbuj wprowadzić je ponownie lub zresetować hasło")),
                        footer = modalButton("OK")
            )
          )
        } else {

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "User logged in",
                                                 lang == "pl" ~ "Zalogowano użytkownika"),
                        p(dplyr::case_when(lang == "eng" ~ "User is logged in succesfully",
                                           lang == "pl" ~ "Użytkownik został poprawnie zalogowany")),
                        footer = modalButton("OK")
            )
          )

          reactive_db$active_user <- temp_data

        }

      })

      #### password reset code sender ####

      observeEvent(input$resetpass_send, {

        temp <- reactive_db$user_db %>%
          filter(user_id == input$resetpass_user_ID)

        if(nrow(temp) == 0){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "User ID not found",
                                                 lang == "pl" ~ "Nazwa użytkownika nie odnaleziona"),
                        p(dplyr::case_when(lang == "eng" ~ "Specified user ID haven't been found in our database. Check if you typed it correctly. If the account wasn't created yet, please register new account.",
                                           lang == "pl" ~ "Nie odnaleziono takiej nazwy użytkownika w naszej bazie danych. Proszę sprawdzić czy nazwa została wprowadzona prawidłowo. Jeżeli konto nie zostało wcześniej utworzone, proszę je najpierw zarejestrować.")),
                        footer = modalButton("OK"))
          )

        } else {

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "Reset code have been send",
                                                 lang == "pl" ~ "Kod resetujący został wysłany"),
                        p(dplyr::case_when(lang == "eng" ~ "Reset code have been send to e-mail that you provided during registration. It will be valid for next 24 hours to reset your password.",
                                           lang == "pl" ~ "Kod resetujący został wysłany na adres e-mail podany podczas rejestracji. Będzie aktywny przez 24h i przez ten czas można go użyć do zresetowania hasła.")),
                        footer = modalButton("OK"))
          )

          reset_code <- paste(floor(runif(10, min = 0, max = 10)), collapse = "")

          reset_mail <- emayili::envelope() %>%
            emayili::to(temp$user_mail) %>%
            emayili::from(gmail_user) %>%
            emayili::subject(paste(appname,
                                   dplyr::case_when(lang == "eng" ~ "password reset code",
                                                    lang == "pl" ~ "kod resetujący hasło"),
                                   sep = " - ")) %>%
            emayili::html(paste0("<p>",
                                 dplyr::case_when(lang == "eng" ~ "In order to reset your password the necessary code has been generated and is available below. Paste it into the application and reset your password.",
                                                  lang == "pl" ~ "Kod wymagany do zresetowania twojego hasła został wygenerowany i jest dostępny poniżej. Wklej go w odpowiednie pole w aplikacji i zresetuj hasło"),"</p><p>",
                                 dplyr::case_when(lang == "eng" ~ "Reset code: ",
                                                  lang == "pl" ~ "Kod resetujący: "),
                                 reset_code, "</p><p>",
                                 dplyr::case_when(lang == "eng" ~ "If you didn't generate that code, check if anyone unauthorized have access to your e-mail inbox. If not, disregard this message.",
                                                  lang == "pl" ~ "Jeżeli nie wygenerowałeś kodu, sprawdź czy ktokolwiek nieupoważniony ma dostęp do twojej skrzynki e-mail. Jeżeli nie, nie zwracaj uwagi na tę wiadomość."),
                                 "</p><p>",
                                 dplyr::case_when(lang == "eng" ~ "This message was generated automatically.</p>",
                                                  lang == "pl" ~ "Ta wiadomość została wygenerowana automatycznie.</p>")))

          smtp <- emayili::server(
            host = "smtp.gmail.com",
            port = 465,
            username = gmail_user,
            password = gmail_password
          )

          smtp(reset_mail)

          temp_row <- tibble("timestamp" = Sys.time(),
                             "user_id" = input$resetpass_user_ID,
                             "reset_code" = scrypt::hashPassword(reset_code))

          reactive_db$reset_db <- rbind(reactive_db$reset_db,
                                        temp_row) %>%
            arrange(desc(timestamp)) %>%
            group_by(user_id) %>%
            slice_head() %>%
            ungroup()

          googlesheets4::sheet_append(gsheet_file,
                                      sheet = "reset_db",
                                      data = temp_row)

        }

        #### password reset #01 ####

      })

      observeEvent(input$resetpass_code_bttn, {

        temp_data <- reactive_db$reset_db %>%
          filter(user_id == input$resetpass_user_ID) %>%
          arrange(desc(timestamp)) %>%
          slice_head() %>%
          filter((Sys.time() - timestamp) < lubridate::period(24, units = "hours"))

        if(nrow(temp_data) == 0){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "Reset code not found",
                                                 lang == "pl" ~ "Nie odnaleziono kodu resetującego"),
                        p(dplyr::case_when(lang == "eng" ~ "There is no active password reset code for specified account. The code is only active for 24 hours after generating. Check if the account ID in box above have been typed properly or if the code was generated within 24 hours.",
                                           lang == "pl" ~ "Nie odnaleziono aktywnego kodu resetującego hasło dla określonego hasła. Utworzony kod jest aktywny jedynie przez 24 godziny. Proszę sprawdzić, czy nazwa użytkownika została wpisana poprawnie w polu powyżej oraz czy kod został wygenerowany w ciągu ostatnic 24 godzin.")),
                        footer = modalButton("OK"))

          )
        } else if(scrypt::verifyPassword(temp_data$reset_code, input$resetpass_code) == F){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "Reset code is not correct",
                                                 lang == "pl" ~ "Wpisany kod jest niepoprawny"),
                        p(dplyr::case_when(lang == "eng" ~ "Provided reset code isn't correct. Check if the code have been copied or typed correctly.",
                                           lang == "pl" ~ "Wpisany kod resetujący nie jest poprawny. Sprawdź czy został on skopiowany lub wpisany odpowiednio.")),
                        footer = modalButton("OK"))
          )

        } else {

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "Reset the password",
                                                 lang == "pl" ~ "Zresetuj hasło"),
                        p(dplyr::case_when(lang == "eng" ~ "Provided reset code is valid. You can now set the new password in the form below.",
                                           lang == "pl" ~ "Wprowadzony kod resetujący jest poprawny. Możesz teraz ustawić nowe hasło korzystając z poniższego formularza.")),
                        passwordInput(session$ns("resetpass1"), dplyr::case_when(lang == "eng" ~ "New password",
                                                                                 lang == "pl" ~ "Nowe hasło")),
                        passwordInput(session$ns("resetpass2"), dplyr::case_when(lang == "eng" ~ "Repeat new password",
                                                                                 lang == "pl" ~ "Powtórz nowe hasło")),
                        htmlOutput(session$ns("resetpass_modal_err")),
                        footer = list(
                          actionButton(session$ns("resetpass_modal_bttn"),
                                       dplyr::case_when(lang == "eng" ~ "Confirm new password",
                                                        lang == "pl" ~ "Potwierdź nowe hasło")),
                          modalButton("OK"))

            )
          )
        }

      })

      #### password reset bttn #02 ####

      observeEvent(input$resetpass_modal_bttn, {

        if(.check_user_login_pass(input$resetpass1) == F){

          output$resetpass_modal_err <- renderText({
            dplyr::case_when(lang == "eng" ~ "Password is not valid. Valid password must consists of 8~20 alphanumeric characters",
                             lang == "pl" ~ "Hasło jest nieprawidłowe. Prawidłowe hasło musi składać się z 8~20 liter i/lub cyfr")
          })
        } else if(input$resetpass1 != input$resetpass2){

          output$resetpass_modal_err <- renderText({
            dplyr::case_when(lang == "eng" ~ "Entered passwords are not identical. Try again.",
                             lang == "pl" ~ "Podane hasła nie są identyczne. Spróbuj ponownie.")
          })

        } else {

          output$resetpass_modal_err <- renderText({
            dplyr::case_when(lang == "eng" ~ "Password changed succesfully. You can use it to log-in on your account.",
                             lang == "pl" ~ "Hasło poprawnie zmienione. Możesz użyć go, aby zalogować się na zwoje konto.")

          })

          mail <- reactive_db$user_db %>%
            filter(user_id == input$resetpass_user_ID) %>%
            arrange(desc(timestamp)) %>%
            slice_head() %>%
            select(user_mail)

          temp_user_data <- tibble(timestamp = Sys.time(),
                                   user_id = input$resetpass_user_ID,
                                   user_mail = as.character(mail),
                                   user_pass = scrypt::hashPassword(input$resetpass1))

          reactive_db$user_id <- rbind(reactive_db$user_id,
                                       temp_user_data) %>%
            arrange(desc(timestamp)) %>%
            group_by(user_id) %>%
            slice_head() %>%
            ungroup()

          googlesheets4::sheet_append(ss = gsheet_file,
                                      sheet = "user_db",
                                      data = temp_user_data)

        }

      })


      #### user register ####

      observeEvent(input$register_bttn, {

        temp_data <- reactive_db$user_db %>%
          filter(user_id == input$register_user_ID)

        if(nrow(temp_data >= 1)){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "User ID non-unique",
                                                 lang == "pl" ~ "Istniejąca nazwa"),
                        p(dplyr::case_when(lang == "eng" ~ "There is an user with that ID in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please user another user ID.",
                                           lang == "pl" ~ "Istnieje już użytkownik o takiej nazwie. Jeżeli stworzono wcześniej konto, proszę spróbować się zalogować lub zresetować hasło. Jeżeli nie tworzono wcześniej konta, proszę użyć innej nazwy użytkownika")),
                        footer = modalButton("OK"))
          )

        } else if(.check_user_login_pass(input$register_user_ID) == F){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "User ID non-valid",
                                                 lang == "pl" ~ "Nieprawidłowa nazwa"),
                        p(dplyr::case_when(lang == "eng" ~ "User ID is not valid. User ID must constists of 8~20 aphanumeric characters.",
                                           lang == "pl" ~ "Nazwa użytkownika jest nieprawidłowa. Powinna składać się z 8~20 liter i/lub cyfr.")),
                        footer = modalButton("OK"))

          )

        }else if(.check_user_mail(input$register_email) == F){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "E-mail not valid",
                                                 lang == "pl" ~ "Niepoprawny adres e-mail"),
                        p(dplyr::case_when(lang == "eng" ~ "Provided e-mail addres isn't valid. Please check if it is correctly typed.",
                                           lang == "pl" ~ "Adres e-mail nie jest poprawny. Proszę sprawdzić, czy został dobrze wpisany.")),
                        footer = modalButton("OK"))
          )

        }else if(.check_user_login_pass(input$register_pass1) == F){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "Non-valid password",
                                                 lang == "pl" ~ "Nieprawidłowe hasło"),
                        p(dplyr::case_when(lang == "eng" ~ "Password is not valid. It must constists of 8~20 aphanumeric characters.",
                                           lang == "pl" ~ "Hasło jest nieprawidłowe. Powinna składać się z 8~20 liter i/lub cyfr.")),
                        footer = modalButton("OK"))

          )
        } else if(input$register_pass1 != input$register_pass2){

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "Passwords don't match",
                                                 lang == "pl" ~ "Hasła nie są identyczne"),
                        p(dplyr::case_when(lang == "eng" ~ "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
                                           lang == "pl" ~ "Wpisane hasła nie zgadzają się. Powtórzone hasło musi być dokładnie takie samo jak pierwsze.")),
                        footer = modalButton("OK"))

          )

        } else {

          showModal(

            modalDialog(title = dplyr::case_when(lang == "eng" ~ "User registered",
                                                 lang == "pl" ~ "Zarejestrowano użytkownika"),
                        p(dplyr::case_when(lang == "eng" ~ "User have been registered succesfully. You should receive an e-mail on account you provided confirming your registration.",
                                           lang == "pl" ~ "Użytkownik został zarejestrowany. Na podany podczas rejestracji adres e-mail powinna dotrzeć wiadomość potwierdzająca rejestrację.")),
                        footer = modalButton("OK"))

          )

          temp_user_data <- tibble(timestamp = Sys.time(),
                                   user_id = input$register_user_ID,
                                   user_mail = input$register_email,
                                   user_pass = scrypt::hashPassword(input$register_pass1))

          reactive_db$user_db <- rbind(reactive_db$user_db, temp_user_data)

          googlesheets4::sheet_append(ss = gsheet_file,
                                      sheet = "user_db",
                                      data = temp_user_data)

          confirmation_mail <- emayili::envelope() %>%
            emayili::to(temp_user_data$user_mail) %>%
            emayili::from(gmail_user) %>%
            emayili::subject(paste(appname,
                                   dplyr::case_when(lang == "eng" ~ "confirmation of registration",
                                                    lang == "pl" ~ "potwierdzenie rejestracji"),
                                   sep = " - ")) %>%
            emayili::html(paste0(
              "<p>",
              dplyr::case_when(lang == "eng" ~ "Thank you for registering an account in our application.",
                               lang == "pl" ~ "Dziękujemy za zarejestrowanie konta w naszej aplikacji."),"</p><p>",
              dplyr::case_when(lang == "eng" ~ "Your user ID: ",
                               lang == "pl" ~ "Twoja nazwa użytkownika: "),
              temp_user_data$user_id, "</p><p>",
              dplyr::case_when(lang == "eng" ~ "You can always visit our application at: ",
                               lang == "pl" ~ "Możesz odwiedzić naszą aplikację pod adresem: "),
              appaddress, "</p><p>",
              dplyr::case_when(lang == "eng" ~ "This message was generated automatically.",
                               lang == "pl" ~ "Ta wiadomość została wygenerowana automatycznie")  ))

          smtp <- emayili::server(
            host = "smtp.gmail.com",
            port = 465,
            username = gmail_user,
            password = gmail_password
          )

          smtp(confirmation_mail)

        }

      })

    }
  )

  return(reactive(reactive_db))

}
