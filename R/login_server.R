#### helper functions - used to check validity of user ID, password and e-mail ####

# user and password is currently required to consists of 8~25 alphanumeric characters

.check_user_login_pass <- function(x){
  nchar(x) >= 8 & nchar(x) <= 25 & grepl("^[[:alnum:]]+$", x)
}

# grepl statement borrowed from https://www.r-bloggers.com/2012/07/validating-email-adresses-in-r/
# Thanks FelixS for great work!

.check_user_mail <- function(x) {
  grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", as.character(x), ignore.case=TRUE)
}

# SQLite get user data

.sqlite_get_db <- function(sqlite_db){
  
  sq_db <- DBI::dbConnect(RSQLite::SQLite(), dbname = sqlite_db)
  
  user_db <- dplyr::tbl(sq_db, "user_db") %>%
    collect() %>%
    mutate(timestamp = as.POSIXct(as.numeric(timestamp), origin = "1970-01-01"))
  
  reset_db <- dplyr::tbl(sq_db, "reset_db") %>%
    collect() %>%
    mutate(timestamp = as.POSIXct(as.numeric(timestamp), origin = "1970-01-01"))
  
  DBI::dbDisconnect(sq_db)
  
  return(
    list(user_db = user_db,
         reset_db = reset_db)
  )
}

# gsheet get user data

.gsheet_get_db <- function(gsheet_db){
  
  user_db = googlesheets4::read_sheet(ss = gsheet_db,
                                      sheet = "user_db") %>%
    dplyr::arrange(dplyr::desc(timestamp)) %>%
    dplyr::group_by(user_id) %>%
    dplyr::slice_head() %>%
    dplyr::ungroup()
  
  reset_db = googlesheets4::read_sheet(ss = gsheet_db,
                                       sheet = "reset_db") %>%
    dplyr::arrange(dplyr::desc(timestamp)) %>%
    dplyr::group_by(user_id) %>%
    dplyr::slice_head() %>%
    dplyr::ungroup()
  
  return(
    list(user_db = user_db,
         reset_db = reset_db)
  )
}

# SQLite new user

.sqlite_new_user <- function(sqlite_db, temp_row){
  
  sq_db <- DBI::dbConnect(RSQLite::SQLite(), sqlite_db)
  
  RSQLite::dbSendQuery(sq_db,
                       "INSERT OR REPLACE INTO user_db (timestamp, user_id, user_mail, user_pass) VALUES (:timestamp, :user_id, :user_mail, :user_pass);",
                       temp_row)
  
  RSQLite::dbDisconnect(sq_db)
  
}

# SQLite send reset

.sqlite_send_reset <- function(sqlite_db, temp_row){
  
  sq_db <- DBI::dbConnect(RSQLite::SQLite(), sqlite_db)
  
  RSQLite::dbSendQuery(sq_db,
                       "INSERT INTO reset_db (timestamp, user_id, reset_code) VALUES (:timestamp, :user_id, :reset_code)
                       ON CONFLICT (user_id) DO UPDATE SET reset_code = :reset_code;",
                       temp_row)
  
  RSQLite::dbDisconnect(sq_db)
}

# SQLite send new pass

.sqlite_new_pass <- function(sqlite_db, temp_row){
  
  sq_db <- DBI::dbConnect(RSQLite::SQLite(), sqlite_db)
  
  RSQLite::dbSendQuery(sq_db,
                       "INSERT INTO user_db (timestamp, user_mail, user_id, user_pass) 
                                     VALUES (:timestamp, :user_mail, :user_id, :user_pass)
                                ON CONFLICT(user_id) DO UPDATE SET user_pass = :user_pass;",
                       temp_row)
  
  RSQLite::dbDisconnect(sq_db)
  
}


#### main server module of the package - googlesheets version ####
#' @title Login server module
#' @name login_server
#' @description Shiny server module for the optional login/registration system
#'
#' This function creates a server module to handle other modules of the system: \code{login_UI()}, \code{password_reset_UI()} and \code{register_UI}
#'
#' It uses database contained in googlesheet file on your gdrive or sqlite database locally to read and write data of the users. You need to create a googlesheet or sqlite database containing at least two sheets/tables with specific columns:
#'
#' - user_db with columns named: \code{timestamp}, \code{user_id}, \code{user_mail} and \code{user_pass}
#' 
#' - reset_db with columns named: \code{timestamp}, \code{user_id}, \code{reset_code}
#' 
#'
#' @param id the id of the module. Defaults to "login_system" for all of the modules contained within the package. If you plan to use serveral login systems inside your app or for any other reason need to change it, remember to keep consistent id for all elements of module.
#' @param db_method the character string containing chosen database container, either: \code{"gsheet"} (needing installation of \code{googlesheets4} package) or \code{"sqlite"} (needing installation of \code{DBI} and \code{RSQLite} packages)
#' @param mail_method the character string containing chosen method of sending emails, either: \code{"gmailr"} (needing installation of \code{gmailr} package) \code{"emayili"} (needing installation of \code{emayili} package)
#' @param appname the character string containing the name of your application (used in automatic e-mails for information purposes)
#' @param appaddress the character value containing the web address of your application (used in automatic e-mails for information purposes)
#' @param lang specifies the app used language. Defaults to "en" for English. Package also supports "pl" for Polish
#' 
#' @param gsheet_file the ID of your googlesheet holding the database. It is contained within URL address of your googlesheet (for: \code{db_method = "gsheet"})
#' @param sqlite_db the path to your SQLite database (for: \code{db_method = "sqlite"})
#' 
#' @param gmailr_user your gmail address (for: \code{db_method = "gmailr"})
#' @param emayili_user your email address, also used as login to your email account (for: \code{db_method = "emayili"})
#' @param emayili_password password to your email account (for: \code{db_method = "emayili"})
#' @param emayili_host host of your email box (for: \code{db_method = "emayili"})
#' @param emayili_port port of your email box (for: \code{db_method = "emayili"})
#'
#' @return reactiveValues() object with three elements:
#' @return \code{is_logged}, containing boolean describing authorization status
#' @return \code{user_id}, containing the logged user identification name. When not logged, it contains the timestamp of session start
#' @return \code{user_mail}, containing the logged user mail. When not logged, it is empty character string of nchar() value 0: ("")
#' 
#' @details 
#'
#' The module logic creates a \code{reactiveValues()} object with loaded database of users and reset codes stored in \code{session$userData}. It allows to cut the reading from database to only one read per loading of the app - unfortunately it makes the app run slowly if the database of users gets very long.
#'
#' Registration of new account mails the confirmation e-mail to the end user on provided e-mail.
#'
#' Provided e-mail is needed for password reset: 10 digits code is generated and mailed to the user to confirm its identity. Reset code remains valid for 24 hours.
#' 
#' ## Authorization
#' 
#' - When using db_method of "gsheet" you need to authorize access to your google drive outside of the functions (using \code{googlesheets4:gs_auth} with default scopes: \code{"https://www.googleapis.com/auth/spreadsheets"})
#' - When using mail_method of "emayili" you need to allow "less secure apps" to use your mailbox
#' - When using mail_method of "gmailr" you need to authorize access to your gmail box by creating Oauth2 App on 'Google Cloud Platform' and passing it to \code{gmailr::gm_auth_configure} and allowing scopes: \code{"https://www.googleapis.com/auth/gmail.send"}
#' 
#' ## Security
#' 
#' - Both passwords and reset codes are hashed with the help of \code{scrypt} package for the extra security
#' - gmailr mail_method seems to be more secure if you intend to use gmail account to send emails. emayili is suggested only when using other mailboxes
#'
#' @seealso [login_UI()] for the login window in UI
#' @seealso [password_reset_UI()] for the password reset window in UI
#' @seealso [register_UI()] for the registration window in UI
#'
#' @export
#' @import shiny
NULL
#' @importFrom dplyr %>%
#' 
#' @example examples/shinybase_sqlite_emayili/app.R


login_server <- function(id = "login_system",
                         db_method,
                         mail_method,
                         appname,
                         appaddress,
                         lang = "en",
                         gsheet_file,
                         sqlite_db,
                         gmailr_user,
                         emayili_user,
                         emayili_password,
                         emayili_host,
                         emayili_port
){
  
  moduleServer(
    id,
    function(input, output, session){
      
      #### checking for packages for handling databases
      
      if(db_method == "gsheet"){
        
        if(length(find.package("googlesheets4", quiet = T)) == 0){
          
          stop("To use this method for database storage, please install googlesheets4 package: install.packages('googlesheets4')")
          
        }
        
      } else if(db_method == "sqlite"){
        
        if(length(find.package("RSQLite", quiet = T)) + length(find.package("DBI", quiet = T)) != 2){
          
          stop("To use this method for database storage, please install DBI and RSQLite packages: install.packages('DBI', 'RSQLite')")
        }
      } else {stop("Valid methods for databases are 'sqlite' or 'gsheet'")}
      #### checking for mail sending method ####
      
      if(mail_method == "emayili"){
        
        if(length(find.package("emayili", quiet = T)) == 0){
          stop("To use this email method, please install emayili package: install.packages('emayili')")
        }
        
      } else if(mail_method == "gmailr"){
        
        if(length(find.package("gmailr", quiet = T)) == 0){
          stop("To use this email method, please install gmailr package: install.packages('gmailr')")
        }
        
      } else{stop("Valid mailing methods are 'gmailr' or 'emayili'")} 
      
      #### reactiveValues initialization ####
      
      active_user <- reactiveValues(
        is_logged = FALSE,
        user_id = Sys.time(),
        user_mail = ""
      )
      
      session$userData$reactive_db <- ({
        
        data = {
          
          if(db_method == "gsheet"){ 
            
            .gsheet_get_db(gsheet_file)
            
          } else if (db_method == "sqlite"){
            
            .sqlite_get_db(sqlite_db)
            
          }}
        
        reactiveValues(
          user_db = data$user_db,
          reset_db = data$reset_db
        )
        
      })
      
      
      #### login observer ####
      
      observeEvent(input$login_button, {
        
        temp_data <- session$userData$reactive_db$user_db %>%
          dplyr::filter(user_id == input$login_user_id) %>%
          dplyr::arrange(dplyr::desc(timestamp)) %>%
          dplyr::group_by(user_id) %>%
          dplyr::slice_head() %>%
          dplyr::ungroup()
        
        if(nrow(temp_data) == 0){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "Username not found",
                                                 lang == "pl" ~ "Nie znaleziono użytkownika"),
                        p(dplyr::case_when(lang == "en" ~ "If the account was registered before, please check if user ID was typed correctly.",
                                           lang == "pl" ~ "Jeżeli konto zostało założone, prosze sprawdzić poprawność wprowadzonej nazwy użytkownika")),
                        p(dplyr::case_when(lang == "en" ~ "If you haven't registered yet, please register new account.",
                                           lang == "pl" ~ "Jeżeli jeszcze nie utworzono konta, proszę się zarejestrować.")),
                        footer = modalButton("OK"))
          )
          
        } else if(scrypt::verifyPassword(as.character(temp_data$user_pass[1]),
                                         input$password_login) == F){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "Wrong password",
                                                 lang == "pl" ~ "Nieprawidłowe hasło"),
                        p(dplyr::case_when(lang == "en" ~ "Typed password doesn't match one in our database. Try again or reset the password.",
                                           lang == "pl" ~ "Wprowadzone hasło jest inne niż powiązane z nazwą użytkownika. Spróbuj wprowadzić je ponownie lub zresetować hasło")),
                        footer = modalButton("OK")
            )
          )
        } else {
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "User logged in",
                                                 lang == "pl" ~ "Zalogowano użytkownika"),
                        p(dplyr::case_when(lang == "en" ~ "User is logged in succesfully",
                                           lang == "pl" ~ "Użytkownik został poprawnie zalogowany")),
                        footer = modalButton("OK")
            )
          )
          
          
          active_user$is_logged <- TRUE
          active_user$user_id <- temp_data$user_id
          active_user$user_mail <- temp_data$user_mail
          
          
        }
        
      })
      
      #### password reset code sender ####
      
      observeEvent(input$resetpass_send, {
        
        temp <- session$userData$reactive_db$user_db %>%
          dplyr::filter(user_id == input$resetpass_user_ID)
        
        if(nrow(temp) == 0){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "User ID not found",
                                                 lang == "pl" ~ "Nazwa użytkownika nie odnaleziona"),
                        p(dplyr::case_when(lang == "en" ~ "Specified user ID haven't been found in our database. Check if you typed it correctly. If the account wasn't created yet, please register new account.",
                                           lang == "pl" ~ "Nie odnaleziono takiej nazwy użytkownika w naszej bazie danych. Proszę sprawdzić czy nazwa została wprowadzona prawidłowo. Jeżeli konto nie zostało wcześniej utworzone, proszę je najpierw zarejestrować.")),
                        footer = modalButton("OK"))
          )
          
        } else {
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "Reset code have been send",
                                                 lang == "pl" ~ "Kod resetujący został wysłany"),
                        p(dplyr::case_when(lang == "en" ~ "Reset code have been send to e-mail that you provided during registration. It will be valid for next 24 hours to reset your password.",
                                           lang == "pl" ~ "Kod resetujący został wysłany na adres e-mail podany podczas rejestracji. Będzie aktywny przez 24h i przez ten czas można go użyć do zresetowania hasła.")),
                        footer = modalButton("OK"))
          )
          
          reset_code <- paste(floor(stats::runif(10, min = 0, max = 10)), collapse = "")
          
          if(mail_method == "gmailr"){
            
            reset_mail <- gmailr::gm_mime() %>%
              gmailr::gm_to(temp$user_mail) %>%
              gmailr::gm_from(gmailr_user) %>%
              gmailr::gm_subject(paste(appname,
                                       dplyr::case_when(lang == "en" ~ "password reset code",
                                                        lang == "pl" ~ "kod resetujący hasło"),
                                       sep = " - ")) %>%
              gmailr::gm_html_body(paste0("<p>",
                                          dplyr::case_when(lang == "en" ~ "In order to reset your password the necessary code has been generated and is available below. Paste it into the application and reset your password.",
                                                           lang == "pl" ~ "Kod wymagany do zresetowania twojego hasła został wygenerowany i jest dostępny poniżej. Wklej go w odpowiednie pole w aplikacji i zresetuj hasło"),"</p><p>",
                                          dplyr::case_when(lang == "en" ~ "Reset code: ",
                                                           lang == "pl" ~ "Kod resetujący: "),
                                          reset_code, "</p><p>",
                                          dplyr::case_when(lang == "en" ~ "If you didn't generate that code, check if anyone unauthorized have access to your e-mail inbox. If not, disregard this message.",
                                                           lang == "pl" ~ "Jeżeli nie wygenerowałeś kodu, sprawdź czy ktokolwiek nieupoważniony ma dostęp do twojej skrzynki e-mail. Jeżeli nie, nie zwracaj uwagi na tę wiadomość."),
                                          "</p><p>",
                                          dplyr::case_when(lang == "en" ~ "This message was generated automatically.</p>",
                                                           lang == "pl" ~ "Ta wiadomość została wygenerowana automatycznie.</p>")))
            
            gmailr::gm_send_message(reset_mail)
            
          } else if(mail_method == "emayili"){
            
            reset_mail <- emayili::envelope() %>%
              emayili::to(temp$user_mail) %>%
              emayili::from(emayili_user) %>%
              emayili::subject(paste(appname,
                                     dplyr::case_when(lang == "en" ~ "password reset code",
                                                      lang == "pl" ~ "kod resetujący hasło"),
                                     sep = " - ")) %>%
              emayili::html(paste0("<p>",
                                   dplyr::case_when(lang == "en" ~ "In order to reset your password the necessary code has been generated and is available below. Paste it into the application and reset your password.",
                                                    lang == "pl" ~ "Kod wymagany do zresetowania twojego hasła został wygenerowany i jest dostępny poniżej. Wklej go w odpowiednie pole w aplikacji i zresetuj hasło"),"</p><p>",
                                   dplyr::case_when(lang == "en" ~ "Reset code: ",
                                                    lang == "pl" ~ "Kod resetujący: "),
                                   reset_code, "</p><p>",
                                   dplyr::case_when(lang == "en" ~ "If you didn't generate that code, check if anyone unauthorized have access to your e-mail inbox. If not, disregard this message.",
                                                    lang == "pl" ~ "Jeżeli nie wygenerowałeś kodu, sprawdź czy ktokolwiek nieupoważniony ma dostęp do twojej skrzynki e-mail. Jeżeli nie, nie zwracaj uwagi na tę wiadomość."),
                                   "</p><p>",
                                   dplyr::case_when(lang == "en" ~ "This message was generated automatically.</p>",
                                                    lang == "pl" ~ "Ta wiadomość została wygenerowana automatycznie.</p>")))
            
            smtp <- emayili::server(
              host = emayili_host,
              port = emayili_port,
              username = emayili_user,
              password = emayili_password
            )
            
            smtp(reset_mail)
            
          }
          
          temp_row <- dplyr::tibble("timestamp" = Sys.time(),
                                    "user_id" = input$resetpass_user_ID,
                                    "reset_code" = scrypt::hashPassword(reset_code))
          
          session$userData$reactive_db$reset_db <- rbind(session$userData$reactive_db$reset_db,
                                                         temp_row) %>%
            dplyr::arrange(desc(timestamp)) %>%
            dplyr::group_by(user_id) %>%
            dplyr::slice_head() %>%
            dplyr::ungroup()
          
          if(db_method == "gsheet"){
            
            googlesheets4::sheet_append(gsheet_file,
                                        sheet = "reset_db",
                                        data = temp_row)
            
          }else if(db_method == "sqlite"){
            
            .sqlite_send_reset(sqlite_db,
                               temp_row)
            
          }
        }
        
        #### password reset #01 ####
        
      })
      
      observeEvent(input$resetpass_code_bttn, {
        
        temp_data <- session$userData$reactive_db$reset_db %>%
          dplyr::filter(user_id == input$resetpass_user_ID) %>%
          dplyr::arrange(desc(timestamp)) %>%
          dplyr::slice_head() %>%
          dplyr::filter((Sys.time() - timestamp) < lubridate::period(24, units = "hours"))
        
        if(nrow(temp_data) == 0){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "Reset code not found",
                                                 lang == "pl" ~ "Nie odnaleziono kodu resetującego"),
                        p(dplyr::case_when(lang == "en" ~ "There is no active password reset code for specified account. The code is only active for 24 hours after generating. Check if the account ID in box above have been typed properly or if the code was generated within 24 hours.",
                                           lang == "pl" ~ "Nie odnaleziono aktywnego kodu resetującego hasło dla określonego hasła. Utworzony kod jest aktywny jedynie przez 24 godziny. Proszę sprawdzić, czy nazwa użytkownika została wpisana poprawnie w polu powyżej oraz czy kod został wygenerowany w ciągu ostatnic 24 godzin.")),
                        footer = modalButton("OK"))
            
          )
        } else if(scrypt::verifyPassword(temp_data$reset_code, input$resetpass_code) == F){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "Reset code is not correct",
                                                 lang == "pl" ~ "Wpisany kod jest niepoprawny"),
                        p(dplyr::case_when(lang == "en" ~ "Provided reset code isn't correct. Check if the code have been copied or typed correctly.",
                                           lang == "pl" ~ "Wpisany kod resetujący nie jest poprawny. Sprawdź czy został on skopiowany lub wpisany odpowiednio.")),
                        footer = modalButton("OK"))
          )
          
        } else {
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "Reset the password",
                                                 lang == "pl" ~ "Zresetuj hasło"),
                        p(dplyr::case_when(lang == "en" ~ "Provided reset code is valid. You can now set the new password in the form below.",
                                           lang == "pl" ~ "Wprowadzony kod resetujący jest poprawny. Możesz teraz ustawić nowe hasło korzystając z poniższego formularza.")),
                        passwordInput(session$ns("resetpass1"), dplyr::case_when(lang == "en" ~ "New password",
                                                                                 lang == "pl" ~ "Nowe hasło")),
                        passwordInput(session$ns("resetpass2"), dplyr::case_when(lang == "en" ~ "Repeat new password",
                                                                                 lang == "pl" ~ "Powtórz nowe hasło")),
                        htmlOutput(session$ns("resetpass_modal_err")),
                        footer = list(
                          actionButton(session$ns("resetpass_modal_bttn"),
                                       dplyr::case_when(lang == "en" ~ "Confirm new password",
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
            dplyr::case_when(lang == "en" ~ "Password is not valid. Valid password must consists of 8~20 alphanumeric characters",
                             lang == "pl" ~ "Hasło jest nieprawidłowe. Prawidłowe hasło musi składać się z 8~20 liter i/lub cyfr")
          })
        } else if(input$resetpass1 != input$resetpass2){
          
          output$resetpass_modal_err <- renderText({
            dplyr::case_when(lang == "en" ~ "Entered passwords are not identical. Try again.",
                             lang == "pl" ~ "Podane hasła nie są identyczne. Spróbuj ponownie.")
          })
          
        } else {
          
          output$resetpass_modal_err <- renderText({
            dplyr::case_when(lang == "en" ~ "Password changed succesfully. You can use it to log-in on your account.",
                             lang == "pl" ~ "Hasło poprawnie zmienione. Możesz użyć go, aby zalogować się na zwoje konto.")
            
          })
          
          mail <- session$userData$reactive_db$user_db %>%
            dplyr::filter(user_id == input$resetpass_user_ID) %>%
            dplyr::arrange(desc(timestamp)) %>%
            dplyr::slice_head() %>%
            dplyr::select(user_mail)
          
          temp_row <- dplyr::tibble(timestamp = Sys.time(),
                                    user_id = input$resetpass_user_ID,
                                    user_mail = as.character(mail),
                                    user_pass = scrypt::hashPassword(input$resetpass1))
          
          session$userData$reactive_db$user_db <- rbind(session$userData$reactive_db$user_db,
                                                        temp_row) %>%
            dplyr::arrange(desc(timestamp)) %>%
            dplyr::group_by(user_id) %>%
            dplyr::slice_head() %>%
            dplyr::ungroup()
          
          if(db_method == "gsheet"){
            
            googlesheets4::sheet_append(ss = gsheet_file,
                                        sheet = "user_db",
                                        data = temp_row)
            
          } else if(db_method == "sqlite"){
            
            .sqlite_new_pass(sqlite_db,
                             temp_row)
            
          }
        }
        
      })
      
      #### user register ####
      
      observeEvent(input$register_bttn, {
        
        temp_data <- session$userData$reactive_db$user_db %>%
          dplyr::filter(user_id == input$register_user_ID)
        
        if(nrow(temp_data >= 1)){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "User ID non-unique",
                                                 lang == "pl" ~ "Istniejąca nazwa"),
                        p(dplyr::case_when(lang == "en" ~ "There is an user with that ID in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please user another user ID.",
                                           lang == "pl" ~ "Istnieje już użytkownik o takiej nazwie. Jeżeli stworzono wcześniej konto, proszę spróbować się zalogować lub zresetować hasło. Jeżeli nie tworzono wcześniej konta, proszę użyć innej nazwy użytkownika")),
                        footer = modalButton("OK"))
          )
          
        } else if(.check_user_login_pass(input$register_user_ID) == F){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "User ID non-valid",
                                                 lang == "pl" ~ "Nieprawidłowa nazwa"),
                        p(dplyr::case_when(lang == "en" ~ "User ID is not valid. User ID must constists of 8~20 aphanumeric characters.",
                                           lang == "pl" ~ "Nazwa użytkownika jest nieprawidłowa. Powinna składać się z 8~20 liter i/lub cyfr.")),
                        footer = modalButton("OK"))
            
          )
          
        }else if(.check_user_mail(input$register_email) == F){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "E-mail not valid",
                                                 lang == "pl" ~ "Niepoprawny adres e-mail"),
                        p(dplyr::case_when(lang == "en" ~ "Provided e-mail addres isn't valid. Please check if it is correctly typed.",
                                           lang == "pl" ~ "Adres e-mail nie jest poprawny. Proszę sprawdzić, czy został dobrze wpisany.")),
                        footer = modalButton("OK"))
          )
          
        }else if(.check_user_login_pass(input$register_pass1) == F){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "Non-valid password",
                                                 lang == "pl" ~ "Nieprawidłowe hasło"),
                        p(dplyr::case_when(lang == "en" ~ "Password is not valid. It must constists of 8~20 aphanumeric characters.",
                                           lang == "pl" ~ "Hasło jest nieprawidłowe. Powinna składać się z 8~20 liter i/lub cyfr.")),
                        footer = modalButton("OK"))
            
          )
        } else if(input$register_pass1 != input$register_pass2){
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "Passwords don't match",
                                                 lang == "pl" ~ "Hasła nie są identyczne"),
                        p(dplyr::case_when(lang == "en" ~ "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
                                           lang == "pl" ~ "Wpisane hasła nie zgadzają się. Powtórzone hasło musi być dokładnie takie samo jak pierwsze.")),
                        footer = modalButton("OK"))
            
          )
          
        } else {
          
          showModal(
            
            modalDialog(title = dplyr::case_when(lang == "en" ~ "User registered",
                                                 lang == "pl" ~ "Zarejestrowano użytkownika"),
                        p(dplyr::case_when(lang == "en" ~ "User have been registered succesfully. You should receive an e-mail on account you provided confirming your registration.",
                                           lang == "pl" ~ "Użytkownik został zarejestrowany. Na podany podczas rejestracji adres e-mail powinna dotrzeć wiadomość potwierdzająca rejestrację.")),
                        footer = modalButton("OK"))
            
          )
          
          temp_row <- dplyr::tibble(timestamp = Sys.time(),
                                    user_id = input$register_user_ID,
                                    user_mail = input$register_email,
                                    user_pass = scrypt::hashPassword(input$register_pass1))
          
          session$userData$reactive_db$user_db <- rbind(session$userData$reactive_db$user_db, temp_row)
          
          if(db_method == "gsheet"){
            
            googlesheets4::sheet_append(ss = gsheet_file,
                                        sheet = "user_db",
                                        data = temp_row)
            
          } else if(db_method == "sqlite"){
            
            .sqlite_new_user(sqlite_db,
                             temp_row)
            
          }
          
          if(mail_method == "emayili"){
            
            confirmation_mail <- emayili::envelope() %>%
              emayili::to(temp_row$user_mail) %>%
              emayili::from(emayili_user) %>%
              emayili::subject(paste(appname,
                                     dplyr::case_when(lang == "en" ~ "confirmation of registration",
                                                      lang == "pl" ~ "potwierdzenie rejestracji"),
                                     sep = " - ")) %>%
              emayili::html(paste0(
                "<p>",
                dplyr::case_when(lang == "en" ~ "Thank you for registering an account in our application.",
                                 lang == "pl" ~ "Dziękujemy za zarejestrowanie konta w naszej aplikacji."),"</p><p>",
                dplyr::case_when(lang == "en" ~ "Your user ID: ",
                                 lang == "pl" ~ "Twoja nazwa użytkownika: "),
                temp_row$user_id, "</p><p>",
                dplyr::case_when(lang == "en" ~ "You can always visit our application at: ",
                                 lang == "pl" ~ "Możesz odwiedzić naszą aplikację pod adresem: "),
                appaddress, "</p><p>",
                dplyr::case_when(lang == "en" ~ "This message was generated automatically.",
                                 lang == "pl" ~ "Ta wiadomość została wygenerowana automatycznie")  ))
            
            smtp <- emayili::server(
              host = emayili_host,
              port = emayili_port,
              username = emayili_user,
              password = emayili_password
            )
            
            smtp(confirmation_mail)
            
          } else {
            
            confirmation_mail <- gmailr::gm_mime() %>%
              gmailr::gm_to(temp_row$user_mail) %>%
              gmailr::gm_from(gmailr_user) %>%
              gmailr::gm_subject(paste(appname,
                                       dplyr::case_when(lang == "en" ~ "confirmation of registration",
                                                        lang == "pl" ~ "potwierdzenie rejestracji"),
                                       sep = " - ")) %>%
              gmailr::gm_html_body(paste0(
                "<p>",
                dplyr::case_when(lang == "en" ~ "Thank you for registering an account in our application.",
                                 lang == "pl" ~ "Dziękujemy za zarejestrowanie konta w naszej aplikacji."),"</p><p>",
                dplyr::case_when(lang == "en" ~ "Your user ID: ",
                                 lang == "pl" ~ "Twoja nazwa użytkownika: "),
                temp_row$user_id, "</p><p>",
                dplyr::case_when(lang == "en" ~ "You can always visit our application at: ",
                                 lang == "pl" ~ "Możesz odwiedzić naszą aplikację pod adresem: "),
                appaddress, "</p><p>",
                dplyr::case_when(lang == "en" ~ "This message was generated automatically.",
                                 lang == "pl" ~ "Ta wiadomość została wygenerowana automatycznie")  ))
            
            gmailr::gm_send_message(confirmation_mail)
            
          }
        }
        
      })
      
      return(active_user)
      
    }
  )
}

