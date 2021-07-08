pkgEnv <- new.env()

pkgEnv$label_en = list(
  ### UI labels ###
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
  ### modal labels ###
 # login
 id_nfound_t = "Username not found",
 id_nfound_1 = "If the account was registered before, please check if user ID was typed correctly.",
 id_nfound_2 = "If you haven't registered yet, please register new account.",
 login_wrong_pass_t = "Wrong password",
 login_wrong_pass_b = "Typed password doesn't match one in our database. Try again or reset the password.",
 login_succ_t = "User logged in",
 login_succ_b = "User is logged in successfully!",
 # reset
 id_nfound_reset = "Specified user ID haven't been found in our database. Check if you typed it correctly. If the account wasn't created yet, please register new account.",
 reset_code_send_t = "Reset code have been send",
 reset_code_send_b = "Reset code have been send to e-mail that you provided during registration. It will be valid for next 24 hours to reset your password.",
 reset_code_nfound_t = "Reset code not found",
 reset_code_nfound_b = "There is no active password reset code for specified account. The code is only active for 24 hours after generating. Check if the account ID in box above have been typed properly or if the code was generated within 24 hours.",
 reset_code_ncorr_t = "Reset code is not correct",
 reset_code_ncorr_b = "Provided reset code isn't correct. Check if the code have been copied or typed correctly.",
 reset_pass_mod_t = "Reset the password",
 reset_pass_mod_b = "Provided reset code is valid. You can now set the new password in the form below.",
 reset_pass_mod_bttn = "Confirm new password",
 reset_pass_mod_nv1 = "Password is not valid. Valid password must consists of 8~25 alphanumeric characters",
 reset_pass_mod_nv2 = "Entered passwords are not identical. Try again.",
 reset_pass_mod_succ ="Password changed succesfully. You can use it to log-in on your account.",
 #register
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
  ### mail labels ###
 mail_automatic = "This message was generated automatically.",
 # reset
 reset_mail_h = "password reset code",
 reset_mail_1 = "In order to reset your password the necessary code has been generated and is available below. Paste it into the application and reset your password.",
 reset_mail_2 = "Reset code: ",
 reset_mail_3 = "If you didn't generate that code, check if anyone unauthorized have access to your e-mail inbox. If not, disregard this message.",
 # register
 reg_mail_h = "confirmation of registration",
 reg_mail_1 = "Thank you for registering an account in our application.",
 reg_mail_2 = "Your user ID: ",
 reg_mail_3 = "You can always visit our application at: "
)

pkgEnv$label_pl = list(
  ### UI labels ###
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
  ### modal labels ###
  # login
 id_nfound_t = "Nie znaleziono użytkownika",
 id_nfound_1 = "Jeżeli konto zostało założone, prosze sprawdzić poprawność wprowadzonej nazwy użytkownika",
 id_nfound_2 = "Jeżeli jeszcze nie utworzono konta, proszę się zarejestrować.",
 login_wrong_pass_t = "Nieprawidłowe hasło",
 login_wrong_pass_b = "Wprowadzone hasło jest inne niż powiązane z nazwą użytkownika. Spróbuj wprowadzić je ponownie lub zresetować hasło.",
 login_succ_t = "Zalogowano użytkownika",
 login_succ_b = "Użytkownik został poprawnie zalogowany!",
  # reset 
 id_nfound_reset = "Nie odnaleziono takiej nazwy użytkownika w naszej bazie danych. Proszę sprawdzić czy nazwa została wprowadzona prawidłowo. Jeżeli konto nie zostało wcześniej utworzone, proszę je najpierw zarejestrować.",
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
 reset_pass_mod_succ = "Hasło poprawnie zmienione. Możesz użyć go, aby zalogować się na zwoje konto.",
  # register
 reg_mod_err1_t = "Istniejąca nazwa użytkownika",
 reg_mod_err1_b = "Istnieje już użytkownik o takiej nazwie. Jeżeli stworzono wcześniej konto, proszę spróbować się zalogować lub zresetować hasło. Jeżeli nie tworzono wcześniej konta, proszę użyć innej nazwy użytkownika",
 reg_mod_err2_t = "Nieprawidłowa nazwa użytkownika",
 reg_mod_err2_b = "Nazwa użytkownika jest nieprawidłowa. Powinna składać się z 8~25 liter i/lub cyfr.",
 reg_mod_err3_t = "Niepoprawny adres e-mail",
 reg_mod_err3_b = "Adres e-mail nie jest poprawny. Proszę sprawdzić, czy został dobrze wpisany.",
 reg_mod_err4_t = "Nieprawidłowe hasło",
 reg_mod_err4_b = "Hasło jest nieprawidłowe. Powinna składać się z 8~25 liter i/lub cyfr.",
 reg_mod_err5_t = "Hasła nie są identyczne",
 reg_mod_err5_b = "Wpisane hasła nie są identyczne. Powtórzone hasło musi być dokładnie takie samo jak pierwsze.",
 reg_mod_succ_t = "Zarejestrowano użytkownika",
 reg_mod_succ_b = "Użytkownik został zarejestrowany. Na podany podczas rejestracji adres e-mail powinna dotrzeć wiadomość potwierdzająca rejestrację.",
  ### mail labels ###
 mail_automatic = "Ta wiadomość została wygenerowana automatycznie",
  # reset
 reset_mail_h = "kod resetujący hasło",
 reset_mail_1 = "Kod wymagany do zresetowania twojego hasła został wygenerowany i jest dostępny poniżej. Wklej go w odpowiednie pole w aplikacji i zresetuj hasło",
 reset_mail_2 = "Kod resetujący: ",
 reset_mail_3 = "Jeżeli nie wygenerowałeś kodu, sprawdź czy ktokolwiek nieupoważniony ma dostęp do twojej skrzynki e-mail. Jeżeli nie, nie zwracaj uwagi na tę wiadomość.",
  # register
 reg_mail_h = "potwierdzenie rejestracji",
 reg_mail_1 = "Dziękujemy za zarejestrowanie konta w naszej aplikacji.",
 reg_mail_2 = "Twoja nazwa użytkownika: ",
 reg_mail_3 = "Możesz odwiedzić naszą aplikację pod adresem: "
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

#' Function for language creation
#' 
#' @name use_language
#' 
#' @param lan give language
#' @export

use_language <- function(lan = "en") {
  txt <- texts$new()
  txt$set_language(lan)
  txt
  
}

