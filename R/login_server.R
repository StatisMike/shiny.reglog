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

#### helper functions for server - SQLite and gsheet databases ####


# SQLite new user

.sqlite_new_user <- function(sqlite_db, temp_row){
  
  sq_db <- DBI::dbConnect(RSQLite::SQLite(), sqlite_db)
  
  new_query <-RSQLite::dbSendQuery(sq_db,
                                   "INSERT INTO user_db (timestamp, user_id, user_mail, user_pass) VALUES (:timestamp, :user_id, :user_mail, :user_pass)
                         ON CONFLICT (user_id) DO UPDATE SET user_pass = :user_pass;",
                                   temp_row)
  
  RSQLite::dbClearResult(new_query)
  
  RSQLite::dbDisconnect(sq_db)
  
}

# SQLite send reset

.sqlite_send_reset <- function(sqlite_db, temp_row){
  
  sq_db <- DBI::dbConnect(RSQLite::SQLite(), sqlite_db)
  
  res_query <- RSQLite::dbSendQuery(sq_db,
                                    "INSERT INTO reset_db (timestamp, user_id, reset_code) VALUES (:timestamp, :user_id, :reset_code)
                                    ON CONFLICT (user_id) DO UPDATE SET reset_code = :reset_code;",
                                    temp_row)
  
  RSQLite::dbClearResult(res_query)
  
  RSQLite::dbDisconnect(sq_db)
}

# SQLite send new pass

.sqlite_new_pass <- function(sqlite_db, temp_row){
  
  sq_db <- DBI::dbConnect(RSQLite::SQLite(), sqlite_db)
  
  pass_query <- RSQLite::dbSendQuery(sq_db,
                                     "INSERT INTO user_db (timestamp, user_mail, user_id, user_pass) 
                                     VALUES (:timestamp, :user_mail, :user_id, :user_pass)
                                     ON CONFLICT(user_id) DO UPDATE SET user_pass = :user_pass;",
                                     temp_row)
  
  RSQLite::dbClearResult(pass_query)
  
  RSQLite::dbDisconnect(sq_db)
  
}

#### helper functions for server - blank multiple inputs

.blank_textInputs <- function(inputs, session){
  for(input in inputs){
    
    updateTextInput(session,
                    inputId = input,
                    value = "")
    
  }
}

#### main server module of the package ####
#' @title Login server module
#' @name login_server
#' @description Shiny server module for the optional login/registration system
#'
#' This function creates a server module to handle other modules of the system: \code{login_UI()}, \code{password_reset_UI()} and \code{register_UI}
#'
#' It uses database contained in 'googlesheet' file on your 'gdrive' or 'SQLite' database locally to read and write data of the users. You need to create a 'googlesheet' or 'SQLite' using \code{create_gsheet_db()} or \code{create_sqlite_db()} respectively.
#' 
#'
#' @param id the id of the module. Defaults to "login_system" for all of the modules contained within the package. If you plan to use serveral login systems inside your app or for any other reason need to change it, remember to keep consistent id for all elements of module.
#' @param db_method the character string containing chosen database container, either: \code{"gsheet"} (needing installation of 'googlesheets4' package) or \code{"sqlite"} (needing installation of 'DBI' and 'RSQLite' packages)
#' @param mail_method the character string containing chosen method of sending emails, either: \code{"gmailr"} (needing installation of 'gmailr' package) \code{"emayili"} (needing installation of 'emayili' package)
#' @param appname the character string containing the name of your application (used in automatic e-mails for information purposes)
#' @param appaddress the character value containing the web address of your application (used in automatic e-mails for information purposes)
#' @param lang specifies the app used language. Accepts "en" or "pl". Defaults to "en"
#' 
#' @param gsheet_file the ID of your 'googlesheet' file holding the database. It is contained within URL address of your googlesheet (for: \code{db_method = "gsheet"})
#' @param sqlite_db the path to your 'SQLite' database (for: \code{db_method = "sqlite"})
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
#' - When using db_method of "gsheet" you need to authorize access to your google drive outside of the functions (using \code{googlesheets4:gs_auth()} with default scopes: \code{"https://www.googleapis.com/auth/spreadsheets"})
#' - When using mail_method of "emayili" you need to allow "less secure apps" to use your mailbox
#' - When using mail_method of "gmailr" you need to authorize access to your gmail box by creating Oauth2 App on 'Google Cloud Platform' and passing it to \code{gmailr::gm_auth_configure()} and allowing scopes: \code{"https://www.googleapis.com/auth/gmail.send"}
#' 
#' ## Security
#' 
#' - Both passwords and reset codes are hashed with the help of 'scrypt' package for the extra security
#' - gmailr mail_method seems to be more secure if you intend to use 'gmail' account to send emails. 'emayili' is suggested only when using other mailboxes.
#'
#' @seealso [login_UI()] for the login window in UI
#' @seealso [password_reset_UI()] for the password reset window in UI
#' @seealso [register_UI()] for the registration window in UI
#'
#' @export
#' @import shiny
NULL
#' @import DBI
#' @import RSQLite
#' 
#' @example examples/apps/shinybase_sqlite_emayili.R


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
                         emayili_port,
                         useLoginModal = TRUE
){
  
  moduleServer(
    id,
    function(input, output, session){
      
      txt <- use_language(lang)
      
      #### checking for packages for handling databases
      
      if(db_method == "gsheet"){
        
        if(length(find.package("googlesheets4", quiet = T)) == 0){
          
          stop("To use this method for database storage, please install 'googlesheets4' package: install.packages('googlesheets4')")
          
        }
        
      } else if(db_method == "sqlite"){
        
        if(length(find.package("RSQLite", quiet = T)) + length(find.package("DBI", quiet = T)) != 2){
          
          stop("To use this method for database storage, please install 'DBI' and 'RSQLite' packages: install.packages('DBI', 'RSQLite')")
        }
      } else {stop("Valid methods for databases are 'sqlite' or 'gsheet'")}
      #### checking for mail sending method ####
      
      if(mail_method == "emayili"){
        
        if(length(find.package("emayili", quiet = T)) == 0){
          stop("To use this email method, please install 'emayili' package: install.packages('emayili')")
        }
        
      } else if(mail_method == "gmailr"){
        
        if(length(find.package("gmailr", quiet = T)) == 0){
          stop("To use this email method, please install 'gmailr' package: install.packages('gmailr')")
        }
        
      } else{stop("Valid mailing methods are 'gmailr' or 'emayili'")} 
      
      #### reactiveValues initialization ####
      
      active_user <- reactiveValues(
        is_logged = FALSE,
        user_id = paste("Anon", as.character(Sys.time()), sep = "_"),
        user_mail = ""
      )
      
      session$userData$reactive_db <- ({
        
        data = {
          
          if(db_method == "gsheet"){ 
            
            gsheet_get_db(gsheet_file)
            
          } else if (db_method == "sqlite"){
            
            sqlite_get_db(sqlite_db)
            
          }}
        
        reactiveValues(
          user_db = data$user_db,
          reset_db = data$reset_db
        )
        
      })
      
      
      #### login observer ####
      
      observeEvent(input$login_button, {
        
        on.exit(.blank_textInputs(inputs = c("login_user_id", "password_login"),
                                  session = session))
        
        temp_data_init <- session$userData$reactive_db$user_db
        temp_data_filtered <- dplyr::filter(temp_data_init, user_id == input$login_user_id)
        temp_data_arranged <- dplyr::arrange(temp_data_filtered, dplyr::desc(timestamp))
        temp_data_grouped <- dplyr::group_by(temp_data_arranged, user_id)
        temp_data_sliced <- dplyr::slice_head(temp_data_grouped)
        temp_data <- dplyr::ungroup(temp_data_sliced)
        
        if(nrow(temp_data) == 0){
          
          showModal(
            
            modalDialog(title = txt$get("id_nfound_t"),
                        p(txt$get("id_nfound_1")),
                        p(txt$get("id_nforun_2")),
                        footer = modalButton("OK"))
            
            
            
          )
          
        } else if(scrypt::verifyPassword(as.character(temp_data$user_pass[1]),
                                         input$password_login) == F){
          
          showModal(
            
            modalDialog(title = txt$get("login_wrong_pass_t"),
                        p(txt$get("login_wrong_pass_b")),
                        footer = modalButton("OK")
            )
          )
        } else {
          
          if (useLoginModal) { showModal(
            
            modalDialog(title = txt$get("login_succ_t"),
                        p(txt$get("login_succ_b")),
                        footer = modalButton("OK")
            )
          ) }
          
          
          active_user$is_logged <- TRUE
          active_user$user_id <- temp_data$user_id
          active_user$user_mail <- temp_data$user_mail
          
          
        }
        
      })
      
      #### password reset code sender ####
      
      observeEvent(input$resetpass_send, {
        
        temp_init <- session$userData$reactive_db$user_db
        temp <- dplyr::filter(temp_init, user_id == input$resetpass_user_ID)
        
        if(nrow(temp) == 0){
          
          showModal(
            
            modalDialog(title = txt$get("id_nfound"),
                        p(txt$get("id_nfound_reset")),
                        footer = modalButton("OK"))
          )
          
        } else {
          
          showModal(
            
            modalDialog(title = txt$get("reset_code_send_t"),
                        p(txt$get("reset_code_send_b")),
                        footer = modalButton("OK"))
          )
          
          reset_code <- paste(floor(stats::runif(10, min = 0, max = 10)), collapse = "")
          
          if(mail_method == "gmailr"){
            
            reset_mail_init <- gmailr::gm_mime()
            reset_mail_w_to <- gmailr::gm_to(reset_mail_init, temp$user_mail)
            reset_mail_w_from <- gmailr::gm_from(reset_mail_w_to, gmailr_user)
            reset_mail_w_sub <- gmailr::gm_subject(reset_mail_w_from,
                                                   paste(appname,
                                                         txt$get("reset_mail_h"),
                                                         sep = " - "))
            reset_mail <- gmailr::gm_html_body(reset_mail_w_sub,
                                               paste0("<p>",
                                                      txt$get("reset_mail_1"),
                                                      "</p><p>",
                                                      txt$get("reset_mail_2"),
                                                      reset_code, 
                                                      "</p><p>",
                                                      txt$get("reset_mail_3"),
                                                      "</p><hr>",
                                                      txt$get("mail_automatic"))
                                               )
            
            gmailr::gm_send_message(reset_mail)
            
          } else if(mail_method == "emayili"){
            
            reset_mail_init <- emayili::envelope()
            reset_mail_w_to <- emayili::to(reset_mail_init, temp$user_mail)
            reset_mail_w_from <- emayili::from(reset_mail_w_to, emayili_user)
            reset_mail_w_sub <- emayili::subject(reset_mail_w_from,
                                                 paste(appname,
                                                       txt$get("reset_mail_h"),
                                                       sep = " - "))
            reset_mail <- emayili::html(reset_mail_w_sub, 
                                        paste0("<p>",
                                               txt$get("reset_mail_1"),
                                               "</p><p>",
                                               txt$get("reset_mail_2"),
                                               reset_code, 
                                               "</p><p>",
                                               txt$get("reset_mail_3"),
                                               "</p><hr>",
                                               txt$get("mail_automatic"))
                                        )
            
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
          
          reset_data_init <- rbind(session$userData$reactive_db$reset_db, temp_row)
          reset_data_arranged <- dplyr::arrange(reset_data_init, dplyr::desc(timestamp))
          reset_data_grouped <- dplyr::group_by(reset_data_arranged, user_id)
          reset_data_sliced <- dplyr::slice_head(reset_data_grouped)
          
          session$userData$reactive_db$reset_db <- dplyr::ungroup(reset_data_sliced)
          
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
        
        temp_data_init <- session$userData$reactive_db$reset_db
        temp_data_filtered <- dplyr::filter(temp_data_init, user_id == input$resetpass_user_ID)
        temp_data_arranged <- dplyr::arrange(temp_data_filtered, dplyr::desc(timestamp))
        temp_data_sliced <- dplyr::slice_head(temp_data_arranged)
        temp_data <- dplyr::filter(temp_data_sliced, (Sys.time() - timestamp) < lubridate::period(24, units = "hours"))
        
        if(nrow(temp_data) == 0){
          
          showModal(
            
            modalDialog(title = txt$get("reset_code_nfound_t"),
                        p(txt$get("reset_code_nfound_b")),
                        footer = modalButton("OK"))
            
          )
        } else if(scrypt::verifyPassword(temp_data$reset_code, input$resetpass_code) == F){
          
          showModal(
            
            modalDialog(title = txt$get("reset_code_ncorr_t"),
                        p(txt$get("reset_code_ncorr_b")),
                        footer = modalButton("OK"))
          )
          
        } else {
          
          showModal(
            
            modalDialog(title = txt$get("reset_pass_mod_t"),
                        p(txt$get("reset_pass_mod_b")),
                        passwordInput(session$ns("resetpass1"), txt$get("password")),
                        passwordInput(session$ns("resetpass2"), txt$get("password_rep")),
                        htmlOutput(session$ns("resetpass_modal_err")),
                        footer = list(
                          actionButton(session$ns("resetpass_modal_bttn"),
                                       label = txt$get("reset_pass_mod_bttn")),
                          modalButton("OK"))
                        
            )
          )
        }
        
      })
      
      #### password reset bttn #02 ####
      
      observeEvent(input$resetpass_modal_bttn, {
        
        if(.check_user_login_pass(input$resetpass1) == F){
          
          output$resetpass_modal_err <- renderText({
            txt$get("reset_pass_mod_nv1")
          })
        } else if(input$resetpass1 != input$resetpass2){
          
          output$resetpass_modal_err <- renderText({
            txt$get("reset_pass_mod_nv2")
          })
          
        } else {
          
          output$resetpass_modal_err <- renderText({
            txt$get("reset_pass_mod_succ")
            
          })
          
          mail_init <- session$userData$reactive_db$user_db
          mail_filtered <- dplyr::filter(mail_init, user_id == input$resetpass_user_ID)
          mail_arranged <- dplyr::arrange(mail_filtered, dplyr::desc(timestamp))
          mail_sliced <- dplyr::slice_head(mail_arranged)
          mail <- dplyr::select(mail_sliced, user_mail)
          
          temp_row <- dplyr::tibble(timestamp = Sys.time(),
                                    user_id = input$resetpass_user_ID,
                                    user_mail = as.character(mail),
                                    user_pass = scrypt::hashPassword(input$resetpass1))
          
          temp_data <- rbind(session$userData$reactive_db$user_db, temp_row)
          temp_data_arranged <- dplyr::arrange(temp_data, dplyr::desc(timestamp))
          temp_data_grouped <- dplyr::group_by(temp_data_arranged, user_id)
          temp_data_sliced <- dplyr::slice_head(temp_data_grouped)
          
          session$userData$reactive_db$user_db <- dplyr::ungroup(temp_data_sliced)
          
          .blank_textInputs(inputs = c("resetpass_user_ID", "resetpass_code", "resetpass1", "resetpass2"),
                            session = session)
          
          updateActionButton(inputId = "resetpass_modal_bttn",
                             icon = icon("thumbs-up"))
          
          
          
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
        
        temp_data <- dplyr::filter(session$userData$reactive_db$user_db,
                                   user_id == input$register_user_ID)
        
        if(nrow(temp_data >= 1)){
          
          on.exit(.blank_textInputs(inputs = c("register_pass1", "register_pass2"),
                                    session = session))
          
          showModal(
            
            modalDialog(title = txt$get("reg_mod_err1_t"),
                        p(txt$get("reg_mod_err1_b")),
                        footer = modalButton("OK"))
          )
          
        } else if(.check_user_login_pass(input$register_user_ID) == F){
          
          on.exit(.blank_textInputs(inputs = c("register_pass1", "register_pass2"),
                                    session = session))
          
          showModal(
            
            modalDialog(title = txt$get("reg_mod_err2_t"),
                        p(txt$get("reg_mod_err2_b")),
                        footer = modalButton("OK"))
            
          )
          
        }else if(.check_user_mail(input$register_email) == F){
          
          on.exit(.blank_textInputs(inputs = c("register_pass1", "register_pass2"),
                                    session = session))
          
          showModal(
            
            modalDialog(title = txt$get("reg_mod_err3_t"),
                        p(txt$get("reg_mod_err3_b")),
                        footer = modalButton("OK"))
          )
          
        }else if(.check_user_login_pass(input$register_pass1) == F){
          
          on.exit(.blank_textInputs(inputs = c("register_pass1", "register_pass2"),
                                    session = session))
          
          showModal(
            
            modalDialog(title = txt$get("reg_mod_err4_t"),
                        p(txt$get("reg_mod_err4_b")),
                        footer = modalButton("OK"))
            
          )
        } else if(input$register_pass1 != input$register_pass2){
          
          on.exit(.blank_textInputs(inputs = c("register_pass1", "register_pass2"),
                                    session = session))
          
          showModal(
            
            modalDialog(title = txt$get("reg_mod_err5_t"),
                        p(txt$get("reg_mod_err5_b")),
                        footer = modalButton("OK"))
            
          )
          
        } else {
          
          on.exit(.blank_textInputs(inputs = c("register_user_ID", "register_email", "register_pass1", "register_pass2"),
                                    session = session))
          
          showModal(
            
            modalDialog(title = txt$get("reg_mod_succ_t"),
                        p(txt$get("reg_mod_succ_b")),
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
            
            confirmation_mail_init <- emayili::envelope()
            confirmation_mail_w_to <- emayili::to(confirmation_mail_init, temp_row$user_mail)
            confirmation_mail_w_from <- emayili::from(confirmation_mail_w_to, emayili_user)
            confirmation_mail_w_sub <- emayili::subject(confirmation_mail_w_from,
                                                        paste(appname,
                                                              txt$get("reg_mail_h")
                                                              ))
            
            confirmation_mail <- emayili::html(confirmation_mail_w_sub, 
                                               paste0(
                                                 "<p>",
                                                 txt$get("reg_mail_1"),
                                                 "</p><p>",
                                                 txt$get("reg_mail_2"),
                                                 temp_row$user_id, 
                                                 "</p><p>",
                                                 txt$get("reg_mail_3"),
                                                 appaddress, 
                                                 "</p><hr>",
                                                 txt$get("mail_automatic"))
            )
            
            smtp <- emayili::server(
              host = emayili_host,
              port = emayili_port,
              username = emayili_user,
              password = emayili_password
            )
            
            smtp(confirmation_mail)
            
          } else {
            
            confirmation_mail_init <- gmailr::gm_mime()
            confirmation_mail_w_to <- gmailr::gm_to(confirmation_mail_init, temp_row$user_mail)
            confirmation_mail_w_from <- gmailr::gm_from(confirmation_mail_w_to, gmailr_user)
            confirmation_mail_w_sub <- gmailr::gm_subject(confirmation_mail_w_from, 
                                                          paste(appname,
                                                                txt$get("reg_mail_h")
                                                          ))
            confirmation_mail <- gmailr::gm_html_body(confirmation_mail_w_sub, 
                                                      paste0(
                                                        "<p>",
                                                        txt$get("reg_mail_1"),
                                                        "</p><p>",
                                                        txt$get("reg_mail_2"),
                                                        temp_row$user_id, 
                                                        "</p><p>",
                                                        txt$get("reg_mail_3"),
                                                        appaddress, 
                                                        "</p><hr>",
                                                        txt$get("mail_automatic"))
            )
            
            gmailr::gm_send_message(confirmation_mail)
            
          }
        }
        
      })
      
      #### user logout 
      
      observeEvent(input$logout_bttn, {
        
        if (active_user$is_logged) {
        
        showModal(
          modalDialog(
            txt$get("logout_modal_title"),
            footer = list(
              actionButton(
                session$ns("logout_accept"),
                txt$get("logout_bttn")
              ),
              modalButton(
                txt$get("logout_unaccept_bttn")
              )
            )
          )
        )} else {
          
          showModal(
            modalDialog(
              txt$get("logout_impossible_modal"),
              footer = modalButton("OK")
            )
          )
        }
        
      })
      
      observeEvent(input$logout_accept, {
        
        active_user$is_logged <- FALSE
        active_user$user_id <- paste("Anon", as.character(Sys.time()), sep = "_")
        active_user$user_mail <- ""
        
        removeModal()
        
      })
      
      return(active_user)
      
    }
  )
}

