RegLog_txts <- new.env()

######     for everyone who wants to add another language support:   ####
# - add new language in '.languages_registered'

RegLog_txts$.languages_registered <- c("i18", "en", "pl")

# - update '.lang_error_call' with information about new language

RegLog_txts$.lang_error_call <- "Currently, only supported languages are English 'en' and Polish 'pl'. You can also use 'i18' to get only the content identifier." 

# add new labels in 'reglog_texts' environment
# remember to escape any non-standard characters using /uXXXX with their unicode

# english texts ####
RegLog_txts$en = list(
  ## UI texts ####
  ### multi-used labels ####
  user_id = "User ID",
  password = "Password",
  email = "E-mail address",
  password_rep = "Repeat the password",
  ### login module specific label ####
  login_bttn = "Log-in",
  ### resetpass module specific labels ####
  reset_ui_1 = "Reset your password",
  reset_ui_2 = "To reset your password, type in your user ID and press the 'Send code' button. The code to reset your password will be sent to the e-mail that you provided during registration.",
  reset_ui_3 = "After receiving a reset e-mail, enter the code in the box below and press the 'Confirm code' button. The reset code will be active for 24 hours.",
  reset_ui_4 = "Received code",
  reset_bttn_1 = "Send code",
  reset_bttn_2 = "Confirm code",
  ### register module specific labels ####
  register_ui_1 = "Registration form",
  register_ui_2 = "In the form below you can register a new account. Choose a user ID, provide a valid e-mail adress and choose a password for your account.",
  register_ui_3 = "User ID and password should consist of 8~25 alphanumeric characters,",
  register_ui_4 = "You should have access to the provided e-mail address. After registration you will receive a confirmation e-mail. Moreover, if you ever forget your password you can reset it with your e-mail.",
  register_bttn = "Register",
  ## modal texts ####
  ### login modals ####
  login_noInput_t = "Missing data",
  login_noInput_b = "To login, please provide your User ID and password.",
  login_success_t = "User logged in!",
  login_success_b = "You have been logged in successfully.",
  login_badId_t = "User ID not found",
  login_badId_b = "If the account was registered before, please check if the user ID was typed correcty. If you haven't registered yet, please register a new account.",
  login_badPass_t = "Wrong password",
  login_badPass_b = "Typed password doesn't match one in our database. Try again or reset the password.",
  ### register modals ####
  register_noInput_t = "Missing data",
  register_noInput_b = "To register, please provided all needed data: chosen user ID, email and password.",
  register_nonValidId_t = "User ID non-valid",
  register_nonValidId_b = "User ID is not valid. User ID must consist of 8~25 aphanumeric characters.",
  register_nonValidEmail_t = "E-mail not valid",
  register_nonValidEmail_b = "Provided e-mail address isn't valid. Please check if it is correctly typed.",
  register_nonValidPass_t = "Non-valid password",
  register_nonValidPass_b = "Password is not valid. It must consist of 8~25 aphanumeric characters.",
  register_notIdenticalPass_t = "Passwords don't match",
  register_notIdenticalPass_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
  register_existingId_t = "User ID non-unique",
  register_existingId_b = "There is an user with that ID in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please use another user ID.",
  register_existingEmail_t = "User email non-unique",
  register_existingEmail_b = "There is an user with that email in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please use another email.",
  register_success_t = "User registered",
  register_success_b = "User has been registered succesfully. You should receive an e-mail at the address you provided confirming your registration.",
  ### credsEdit modals ####
  credsEdit_noInput_pass_t = "Missing data",
  credsEdit_noInput_pass_b = "To change you password, please provide both current user ID and password alongside new password.",
  credsEdit_noInput_other_t = "Missing data",
  credsEdit_noInput_other_b = "To change your user ID and/or email, please provide both current user ID and password alongside new user ID and/or email.",
  credsEdit_badId_t = "User ID not found",
  credsEdit_badId_b = "Provided current user ID isn't found in our database",
  credsEdit_badPass_t = "Wrong password",
  credsEdit_badPass_b = "Typed current password doesn't match the one in our database. Try again or reset the password.",
  credsEdit_nonValidId_t = "User ID non-valid",
  credsEdit_nonValidId_b = "Provided new user ID isn't valid. User ID must consist of 8~25 alphanumeric characters.",
  credsEdit_nonValidPass_t = "Non-valid password",
  credsEdit_nonValidPass_b = "Provided new password isn't valid. Password must consist of 8~25 alphanumeric characters.",
  credsEdit_nonValidEmail_t = "Non-valid email",
  credsEdit_nonValidEmail_b = "Provided new e-mail address isn't valid. Please check if it is correctly typed.",
  credsEdit_notIdenticalPass_t = "Passwords don't match",
  credsEdit_notIdenticalPass_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
  credsEdit_existingId_t = "User ID non-unique",
  credsEdit_existingId_b = "The provided new user ID already exists in our database. Please try another user ID.",
  credsEdit_existingEmail_t = "User e-mail non-unique",
  credsEdit_existingEmail_b = "The provided new e-mail address already exists in our database. Please try another e-mail.",
  credsEdit_success_t = "Successful edit",
  credsEdit_success_b = "The user data have been changed successfully.",
  ### resetPass modals ####
  resetPass_noInput_generate_t = "Missing data",
  resetPass_noInput_generate_b = "To generate new reset code and have it send to your e-mail please provide your user ID",
  resetPass_noInput_confirm_t = "Missing data",
  resetPass_noInput_confirm_b = "To reset password with received reset code, please provide your user ID, received code and new password.",
  resetPass_nonValidPass_t = "Non-valid password",
  resetPass_nonValidPass_b = "Provided new password isn't valid. Password must consist of 8-25 alphanumeric characters.",
  resetPass_notIdenticalPass_t = "Passwords don't match.",
  resetPass_notIdenticalPass_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
  resetPass_badId_t = "User ID not found",
  resetPass_badId_b = "Provided user ID isn't found in our database.",
  resetPass_invalidCode_t = "Incorrect reset code",
  resetPass_invalidCode_b = "Provided reset code isn't correct. Check if the code has been copied or typed in correctly.",
  ### logout modal ####
  logout_notLogIn_t = "Cannot log-out",
  logout_notLogIn_b = "You aren't logged in.",
  logout_success_t = "Logged out",
  logout_success_b = "You have been successfully logged out",
  ## mail labels ####
  mail_automatic = "This message was generated automatically.",
  # reset
  reset_mail_h = "password reset code",
  reset_mail_1 = "In order to reset your password the necessary code has been generated and is available below. Paste it into the application and reset your password.",
  reset_mail_2 = "Reset code: ",
  reset_mail_3 = "If you didn't generate that code, check if anyone unauthorized has access to your e-mail inbox. If not, disregard this message.",
  # register
  reg_mail_h = "confirmation of registration",
  reg_mail_1 = "Thank you for registering an account in our application.",
  reg_mail_2 = "Your user ID: ",
  reg_mail_3 = "You can always visit our application at: ",
  # logout
  logout_bttn = "Log-out",
  # creds_edit
  cred_edit_ui_h1 = "Edit your information",
  cred_eidt_ui_p = "Here you can change your information. After successful change you will be relogged using your updated data.",
  cred_edit_ui_h2_old = "Your current data",
  cred_edit_ui_p_old = "As you are going to edit your information, please provide your current username and password below to confirm your identity before trying to trigger any changes.",
  cred_edit_ui_h2_pass_change = "Change your current password",
  cred_edit_ui_p_pass_change = "Provide your new password below to change your password.",
  cred_edit_pass_change_bttn = "Confirm password change",
  cred_edit_ui_h2_other_change = "Change user data",
  cred_edit_ui_p_other_change = "Provide new user ID and/or new email to change them.",
  cred_edit_other_change_bttn = "Confirm change of user data"
)

RegLog_txts$pl = list(
  ### polish labels ####
  # multi-used labels
  user_id = "Nazwa u\u017Cytkownika",
  password = "Has\u0142o",
  email = "Adres e-mail",
  password_rep = "Powt\u00F3rz has\u0142o",
  # login_ui specific label
  login_bttn = "Zaloguj",
  # resetpass_ui specific label
  reset_ui_1 = "Reset has\u0142a",
  reset_ui_2 = "Aby zresetowa\u0107 has\u0142o, wprowad\u017A swoj\u0105 nazw\u0119 u\u017Cytkownika i wci\u015Bnij przycisk 'Wy\u015Blij kod'. Kod do zresetowania has\u0142a zostanie wys\u0142any na e-mail podany podczas rejestracji. Wiadomo\u015B\u0107 powinna dotrze\u0107 w ci\u0105gu kilku minut.",
  reset_ui_3 = "Po otrzymaniu wiadomo\u015Bci wprowad\u017A otrzymany kod w pole poni\u017Cej i wci\u015Bnij przycisk 'Potwierd\u017A kod'. Kod b\u0119dzie aktywny przez 24 godziny.",
  reset_ui_4 = "Otrzymany kod",
  reset_bttn_1 = "Wy\u015Blij kod",
  reset_bttn_2 = "Potwierd\u017A kod",
  # register module specific labels
  register_ui_1 = "Formularz rejestracyjny",
  register_ui_2 = "W poni\u017Cszym formularzu mo\u017Cna zarejetrowa\u0107 nowe konto. Wybierz nazw\u0119 u\u017Cytkownika, podaj poprawny adres e-mail i wybierz has\u0142o dla swojego konta.",
  register_ui_3 = "Nazwa u\u017Cytkownika i has\u0142o powinny sk\u0142ada\u0107 si\u0119 z 8~25 liter i/lub cyfr.",
  register_ui_4 = "Podany adres e-mail powinien dla ciebie dost\u0119pny. Po rejestracji otrzymasz wiadomo\u015B\u0107 potwierdzaj\u0105c\u0105. Co wi\u0119cej, je\u017Celi kiedykolwiek zapomnisz swojego has\u0142a, mo\u017Cesz je zresetowa\u0107 poprzez e-mail.",
  register_bttn = "Zarejestruj",
  ## modal texts ####
  ### login modals ####
  login_noInput_t = "Missing data",
  login_noInput_b = "To login, please provide your User ID and password.",
  login_success_t = "User logged in!",
  login_success_b = "You have been logged in successfully.",
  login_badId_t = "User ID not found",
  login_badId_b = "If the account was registered before, please check if the user ID was typed correcty. If you haven't registered yet, please register a new account.",
  login_badPass_t = "Wrong password",
  login_badPass_b = "Typed password doesn't match one in our database. Try again or reset the password.",
  ### register modals ####
  register_noInput_t = "Missing data",
  register_noInput_b = "To register, please provided all needed data: chosen user ID, email and password.",
  register_nonValidId_t = "User ID non-valid",
  register_nonValidId_b = "User ID is not valid. User ID must consist of 8~25 aphanumeric characters.",
  register_nonValidEmail_t = "E-mail not valid",
  register_nonValidEmail_b = "Provided e-mail address isn't valid. Please check if it is correctly typed.",
  register_nonValidPass_t = "Non-valid password",
  register_nonValidPass_b = "Password is not valid. It must consist of 8~25 aphanumeric characters.",
  register_notIdenticalPass_t = "Passwords don't match",
  register_notIdenticalPass_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
  register_existingId_t = "User ID non-unique",
  register_existingId_b = "There is an user with that ID in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please use another user ID.",
  register_existingEmail_t = "User email non-unique",
  register_existingEmail_b = "There is an user with that email in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please use another email.",
  register_success_t = "User registered",
  register_success_b = "User has been registered succesfully. You should receive an e-mail at the address you provided confirming your registration.",
  ### credsEdit modals ####
  credsEdit_noInput_pass_t = "Missing data",
  credsEdit_noInput_pass_b = "To change you password, please provide both current user ID and password alongside new password.",
  credsEdit_noInput_other_t = "Missing data",
  credsEdit_noInput_other_b = "To change your user ID and/or email, please provide both current user ID and password alongside new user ID and/or email.",
  credsEdit_badId_t = "User ID not found",
  credsEdit_badId_b = "Provided current user ID isn't found in our database",
  credsEdit_badPass_t = "Wrong password",
  credsEdit_badPass_b = "Typed current password doesn't match the one in our database. Try again or reset the password.",
  credsEdit_nonValidId_t = "User ID non-valid",
  credsEdit_nonValidId_b = "Provided new user ID isn't valid. User ID must consist of 8~25 alphanumeric characters.",
  credsEdit_nonValidPass_t = "Non-valid password",
  credsEdit_nonValidPass_b = "Provided new password isn't valid. Password must consist of 8~25 alphanumeric characters.",
  credsEdit_nonValidEmail_t = "Non-valid email",
  credsEdit_nonValidEmail_b = "Provided new e-mail address isn't valid. Please check if it is correctly typed.",
  credsEdit_notIdenticalPass_t = "Passwords don't match",
  credsEdit_notIdenticalPass_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
  credsEdit_existingId_t = "User ID non-unique",
  credsEdit_existingId_b = "The provided new user ID already exists in our database. Please try another user ID.",
  credsEdit_existingEmail_t = "User e-mail non-unique",
  credsEdit_existingEmail_b = "The provided new e-mail address already exists in our database. Please try another e-mail.",
  credsEdit_success_t = "Successful edit",
  credsEdit_success_b = "The user data have been changed successfully.",
  ### resetPass modals ####
  resetPass_noInput_generate_t = "Missing data",
  resetPass_noInput_generate_b = "To generate new reset code and have it send to your e-mail please provide your user ID",
  resetPass_noInput_confirm_t = "Missing data",
  resetPass_noInput_confirm_b = "To reset password with received reset code, please provide your user ID, received code and new password.",
  resetPass_nonValidPass_t = "Non-valid password",
  resetPass_nonValidPass_b = "Provided new password isn't valid. Password must consist of 8-25 alphanumeric characters.",
  resetPass_notIdenticalPass_t = "Passwords don't match.",
  resetPass_notIdenticalPass_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
  resetPass_badId_t = "User ID not found",
  resetPass_badId_b = "Provided user ID isn't found in our database.",
  resetPass_invalidCode_t = "Incorrect reset code",
  resetPass_invalidCode_b = "Provided reset code isn't correct. Check if the code has been copied or typed in correctly.",
  ### logout modal ####
  logout_notLogIn_t = "Cannot log-out",
  logout_notLogIn_b = "You aren't logged in.",
  logout_success_t = "Logged out",
  logout_success_b = "You have been successfully logged out",
  ### mail labels ###
  mail_automatic = "Ta wiadomo\u015B\u0107 zosta\u0142a wygenerowana automatycznie",
  # reset
  reset_mail_h = "kod resetuj\u0105cy has\u0142o",
  reset_mail_1 = "Kod wymagany do zresetowania twojego has\u0142a zosta\u0142 wygenerowany i jest dost\u0119pny poni\u017Cej. Wklej go w odpowiednie pole w aplikacji i zresetuj has\u0142o",
  reset_mail_2 = "Kod resetuj\u0105cy: ",
  reset_mail_3 = "Je\u017Celi nie wygenerowa\u0142e\u015B kodu, sprawd\u017A czy ktokolwiek nieupowa\u017Cniony ma dost\u0119p do twojej skrzynki e-mail. Je\u017Celi nie, nie zwracaj uwagi na t\u0119 wiadomo\u015B\u0107.",
  # register
  reg_mail_h = "potwierdzenie rejestracji",
  reg_mail_1 = "Dzi\u0119kujemy za zarejestrowanie konta w naszej aplikacji.",
  reg_mail_2 = "Twoja nazwa u\u017Cytkownika: ",
  reg_mail_3 = "Mo\u017Cesz odwiedzi\u0107 nasz\u0105 aplikacj\u0119 pod adresem: ",
  # logout bttn
  logout_bttn = "Wyloguj",
  logout_modal_title = "Czy na pewno chcesz si\u0119 wylogowa\u0107?",  # deprecated
  logout_unaccept_bttn = "Nie wylogowuj!",                              # deprecated
  logout_impossible_modal = "Nie jeste\u015B jeszcze zalogowany.",      # deprecated
  logout_mod_t = "Wylogowano",
  logout_mod_b = "Pomy\u015Blnie wylogowano!",
  # creds_edit
  cred_edit_ui_h1 = "Zmień swoje dane",
  cred_eidt_ui_p = "Tutaj możesz zmienić swoje dane. Po pomyślnej zmianie nastąpi przelogowanie z wykorzystaniem zaktualizowanych danych.",
  cred_edit_ui_h2_old = "Potwierdź tożasamość",
  cred_edit_ui_p_old = "Przed zatwierdzeniem jakichkolwiek zmian, proszę o potwierdzenie swojej tożsamości z wykorzystaniem obecnej nazwy użytkownika i hasła.",
  cred_edit_ui_h2_pass_change = "Zmień obecne hasło",
  cred_edit_ui_p_pass_change = "Wpisz i potwierdź nowe hasło poniżej.",
  cred_edit_pass_change_bttn = "Zatwierdź zmianę hasła",
  cred_edit_ui_h2_other_change = "Zmień dane użytkownika",
  cred_edit_ui_p_other_change = "Wpisz nową nazwę użytkownika i/lub nowy adres e-mail.",
  cred_edit_other_change_bttn = "Zatwierdź zmianę danych użytkownika"
)

# also - modify documentation in RegLogServer argument `lang`

#' Getting texts for given language
#'
#' @param lang character to identify the language
#' @param x character to identify the txt to get. If NULL, all labels are
#' recovered
#' @param custom_txts named list providing custom messages to replace default for
#' specific languages. 
#'
#' @details
#' 'RegLog_txt' outside of internal usage should be used only for getting the
#' structure of all texts generated by 'shiny.reglog'.
#'
#' To customize texts used by RegLog objects, provide within their 
#' call named list to the 'custom_txts' argument - it will be passed to 'custom_txts'
#' within this call. You can check validity of your list by providing the 'custom_txts'
#' and calling this function in console.
#' 
#' Values of list provided should be named in the same way as the default text 
#' you are willing to replace.
#'
#' @export
#'

RegLog_txt <- function(
  lang,
  x = NULL,
  custom_txts = NULL
) {
  
  # check if the lang is in registered languages
  if (!lang %in% RegLog_txts$.languages_registered) {
    stop(RegLog_txts$.lang_error_call, call.= F)
  }
  
  # if custom_txts is null, acquire defaults txts
  
  if (is.null(custom_txts)) {
    
    if (is.null(x)) {
      return(RegLog_txts[[as.character(lang)]])
    } else {
      return(RegLog_txts[[as.character(lang)]][[as.character(x)]])
    }
    
    # if custom_txts are provided, return default value only if there is no
    # custom text for element
    
  } else {
    
    # without providing x, return the whole list
    
    if (is.null(x)) {
      customized <- lapply(
        seq_along(reglog_texts[[as.character(lang)]]),
        \(i) {
          custom_txt <- custom_txts[[names(reglog_texts[[as.character(lang)]])[i]]]
          if (is.null(custom_txt)) {
            return(reglog_texts[[as.character(lang)]][[i]])
          } else {
            return(custom_txt)
          }
        })
      return(customized)
      
      # with x provided, return only this one element
    } else {
      default_txt <- reglog_texts[[as.character(lang)]][[as.character(x)]]
      custom_txt <- custom_txts[[as.character(x)]]
      
      if (is.null(custom_txt)) {
        if (!is.null(default_txt))  return(default_txt)
        else return(x)
      } else {
        return(custom_txt)
      }
    }
  }
}

