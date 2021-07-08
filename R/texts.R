pkgEnv <- new.env()

pkgEnv$label_en = list(
  # multi-used labels
 user_id = "User ID",
 password = "Password",
 email = "E-mail adress",
 password_rep = "Repeat the password",
  # login module specific label
 login_bttn = "Log-in",
  # resetpass module specific labels
 reset_ui_1 = "Reset your password",
 reset_ui_2 = "To reset your password, type in your user ID and press the 'Send code' button. The code to reset your password will be send to the e-mail that you provided during the registration.",
 reset_ui_3 = "After getting the e-mail type the received code in the box below and press the 'Confirm code' button. The code will be active for 24 hours.",
 reset_ui_4 = "Received code",
 reset_bttn_1 = "Send code",
 reset_bttn_2 = "Confirm code",
  # register module specific labels
 register_ui_1 = "Registration form",
 register_ui_2 = "In the form below you can register a new account. Choose an user ID, provide a valid e-mail adress and choose a password for your account.",
 register_ui_3 = "User ID and password should constist of 8~25 alphanumeric characters,",
 register_ui_4 = "You should have access to provided e-mail address. After registration you will receive confirmation e-mail. Moreover, if you ever forget your password you can reset it with your e-mail.",
 register_bttn = "Register",
  # modal messages
 id_nfound_t = "Username not found",
 id_nfound_1 = "If the account was registered before, please check if user ID was typed correctly.",
 id_nfound_2 = "If you haven't registered yet, please register new account.",
 id_nfound_reset = "Specified user ID haven't been found in our database. Check if you typed it correctly. If the account wasn't created yet, please register new account.",
 login_wrong_pass_t = "Wrong password",
 login_wrong_pass_b = "Typed password doesn't match one in our database. Try again or reset the password.",
 reset_code_send_t = "Reset code have been send",
 reset_code_send_b = "Reset code have been send to e-mail that you provided during registration. It will be valid for next 24 hours to reset your password.",
 reset_code_nfound_t = "Reset code not found",
 reset_code_nfound_b = "There is no active password reset code for specified account. The code is only active for 24 hours after generating. Check if the account ID in box above have been typed properly or if the code was generated within 24 hours.",
 reset_code_ncorr_t = "Reset code is not correct",
 reset_code_ncorr_b = "Provided reset code isn't correct. Check if the code have been copied or typed correctly.",
 reset_pass_mod_t = "Reset the password",
 reset_pass_mod_b = "Provided reset code is valid. You can now set the new password in the form below.",
 reset_pass_mod_bttn = "Confirm new password",
 reset_pass_mod_nv1 = "Password is not valid. Valid password must consists of 8~20 alphanumeric characters",
 reset_pass_mod_nv2 = "Entered passwords are not identical. Try again.",
 reset_pass_mod_succ ="Password changed succesfully. You can use it to log-in on your account.",
 reg_mod_err1_t = "User ID non-unique",
 reg_mod_err1_b = "There is an user with that ID in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please user another user ID.",
 reg_mod_err2_t = "User ID non-valid",
 reg_mod_err2_b = "User ID is not valid. User ID must constists of 8~25 aphanumeric characters.",
 reg_mod_err3_t = "E-mail not valid",
 reg_mod_err3_b = "Provided e-mail addres isn't valid. Please check if it is correctly typed.",
 reg_mod_err4_t = "Non-valid password",
 reg_mod_err4_b = "Password is not valid. It must constists of 8~25 aphanumeric characters.",
 reg_mod_err5_t = "Passwords don't match",
 reg_mod_err5_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
 reg_mod_succ_t = "User registered",
 reg_mod_succ_b = "User have been registered succesfully. You should receive an e-mail on account you provided confirming your registration.",
  #mail messages
 
)

pkgEnv$label_pl = list(
  # multi-used labels
 user_id = "Nazwa użytkownika",
 password = "Hasło",
 email = "Adres e-mail",
 password_rep = "Powtórz hasło",
  # login_ui specific label
 login_bttn = "Zaloguj",
  # resetpass_ui specific label
 reset_ui_1 = "Reset hasła",
 reset_ui_2 = "Aby zresetować hasło, wprowadź swoją nazwę użytkownika i wciśnij przycisk 'Wyślij kod'. Kod do zresetowania hasła zostanie wysłany na e-mail podany podczas rejestracji. Wiadomość powinna dotrzeć w ciągu kilku minut.",
 reset_ui_3 = "Po otrzymaniu wiadomości wprowadź otrzymany kod w pole poniżej i wciśnij przycisk 'Potwierdź kod'. Kod będzie aktywny przez 24 godziny.",
 reset_ui_4 = "Otrzymany kod",
 reset_bttn_1 = "Wyślij kod",
 reset_bttn_2 = "Potwierdź kod",
  # register module specific labels
 register_ui_1 = "Formularz rejestracyjny",
 register_ui_2 = "W poniższym formularzu można zarejetrować nowe konto. Wybierz nazwę użytkownika, podaj poprawny adres e-mail i wybierz hasło dla swojego konta.",
 register_ui_3 = "Nazwa użytkownika i hasło powinny składać się z 8~25 liter i/lub cyfr.",
 register_ui_4 = "Podany adres e-mail powinien dla ciebie dostępny. Po rejestracji otrzymasz wiadomość potwierdzającą. Co więcej, jeżeli kiedykolwiek zapomnisz swojego hasła, możesz je zresetować poprzez e-mail.",
 register_bttn = "Zarejestruj",
  # modal messages
 id_nfound_t = "Nie znaleziono użytkownika",
 id_nfound_1 = "Jeżeli konto zostało założone, prosze sprawdzić poprawność wprowadzonej nazwy użytkownika",
 id_nfound_2 = "Jeżeli jeszcze nie utworzono konta, proszę się zarejestrować.",
 id_nfound_reset = "Nie odnaleziono takiej nazwy użytkownika w naszej bazie danych. Proszę sprawdzić czy nazwa została wprowadzona prawidłowo. Jeżeli konto nie zostało wcześniej utworzone, proszę je najpierw zarejestrować.",
 login_wrong_pass_t = "Nieprawidłowe hasło",
 login_wrong_pass_b = "Wprowadzone hasło jest inne niż powiązane z nazwą użytkownika. Spróbuj wprowadzić je ponownie lub zresetować hasło.",
 reset_code_send_t = "Kod resetujący został wysłany",
 reset_code_send_b = "Kod resetujący został wysłany na adres e-mail podany podczas rejestracji. Będzie aktywny przez 24h i przez ten czas można go użyć do zresetowania hasła.",
 reset_code_nfound_t = "Nie odnaleziono kodu resetującego",
 reset_code_nfound_b = "Nie odnaleziono aktywnego kodu resetującego hasło dla określonego hasła. Utworzony kod jest aktywny jedynie przez 24 godziny. Proszę sprawdzić, czy nazwa użytkownika została wpisana poprawnie w polu powyżej oraz czy kod został wygenerowany w ciągu ostatnic 24 godzin.",
 reset_code_ncorr_t = "Wpisany kod jest niepoprawny",
 reset_code_ncorr_b = "Wpisany kod resetujący nie jest poprawny. Sprawdź czy został on skopiowany lub wpisany odpowiednio.",
 reset_pass_mod_t = "Zresetuj hasło",
 reset_pass_mod_b = "Wprowadzony kod resetujący jest poprawny. Możesz teraz ustawić nowe hasło korzystając z poniższego formularza.",
 reset_pass_mod_bttn = "Potwierdź nowe hasło",
 reset_pass_mod_nv1 = "Hasło jest nieprawidłowe. Prawidłowe hasło musi składać się z 8~25 liter i/lub cyfr",
 reset_pass_mod_nv2 = "Podane hasła nie są identyczne. Spróbuj ponownie.",
 reset_pass_mod_succ ="Password changed succesfully. You can use it to log-in on your account.",
 reg_mod_err1_t = "User ID non-unique",
 reg_mod_err1_b = "There is an user with that ID in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please user another user ID.",
 reg_mod_err2_t = "User ID non-valid",
 reg_mod_err2_b = "User ID is not valid. User ID must constists of 8~25 aphanumeric characters.",
 reg_mod_err3_t = "E-mail not valid",
 reg_mod_err3_b = "Provided e-mail addres isn't valid. Please check if it is correctly typed.",
 reg_mod_err4_t = "Non-valid password",
 reg_mod_err4_b = "Password is not valid. It must constists of 8~20 aphanumeric characters.",
 reg_mod_err5_t = "Passwords don't match",
 reg_mod_err5_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
 reg_mod_succ_t = "User registered",
 reg_mod_succ_b = "User have been registered succesfully. You should receive an e-mail on account you provided confirming your registration.",
  #mail messages
)

v_language_registered = c("en", "pl")
names(v_language_registered) = c("English", "Polski")

#' @importFrom R6 R6Class
#' @importFrom utils modifyList
texts <- R6::R6Class(
  classname = "shiny.reglog_txts",
  public = list(
    initialize = function() {
      invisible(self)
    },
    set_language = function(lan) {
      if (!lan %in% private$language_registered) {
        stop("Unsupported language !", call. = FALSE)
      }
      private$language <- lan
      private$labels <-   switch (lan,
                                  "en" = pkgEnv$label_en,
                                  "pl" = pkgEnv$label_pl
      )
    },
    get = function(label) {
      value <- private$labels[[label]]
      if(is.null(value)){
        label
      } else {
        value
      }
    },
    get_language_registered = function() {
      private$language_registered
    },
    get_language = function() {
      private$language
    }
  ),
  private = list(
    language = "en",
    language_registered = v_language_registered,
    labels = pkgEnv$label_en
  )
)

use_language <- function(lan = "en") {
  txt <- texts$new()
  txt$set_language(lan)
  txt
}

