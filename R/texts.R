# Idea for creation the `texts` R6 object taken inspired by `shinymanager`
# package. Thanks for their great code!

pkgEnv <- new.env()

pkgEnv$label_en = list(
  ### UI labels ###
  # multi-used labels
 user_id = "User ID",
 password = "Password",
 email = "E-mail address",
 password_rep = "Repeat the password",
  # login module specific label
 login_bttn = "Log-in",
  # resetpass module specific labels
 reset_ui_1 = "Reset your password",
 reset_ui_2 = "To reset your password, type in your user ID and press the 'Send code' button. The code to reset your password will be sent to the e-mail that you provided during registration.",
 reset_ui_3 = "After receiving a reset e-mail, enter the code in the box below and press the 'Confirm code' button. The reset code will be active for 24 hours.",
 reset_ui_4 = "Received code",
 reset_bttn_1 = "Send code",
 reset_bttn_2 = "Confirm code",
  # register module specific labels
 register_ui_1 = "Registration form",
 register_ui_2 = "In the form below you can register a new account. Choose a user ID, provide a valid e-mail adress and choose a password for your account.",
 register_ui_3 = "User ID and password should consist of 8~25 alphanumeric characters,",
 register_ui_4 = "You should have access to the provided e-mail address. After registration you will receive a confirmation e-mail. Moreover, if you ever forget your password you can reset it with your e-mail.",
 register_bttn = "Register",
  ### modal labels ###
 # login
 id_nfound_t = "Username not found",
 id_nfound_1 = "If the account was registered before, please check if the user ID was typed correctly.",
 id_nfound_2 = "If you haven't registered yet, please register a new account.",
 login_wrong_pass_t = "Wrong password",
 login_wrong_pass_b = "Typed password doesn't match one in our database. Try again or reset the password.",
 login_succ_t = "User logged in",
 login_succ_b = "User is logged in successfully!",
 # reset
 id_nfound_reset = "Specified user ID not found in our database. Check if you typed it correctly. If the account wasn't created yet, please register a new account.",
 reset_code_send_t = "Reset code has been sent",
 reset_code_send_b = "Reset code has been sent to the e-mail that you provided during registration. It will be valid for the next 24 hours to reset your password.",
 reset_code_nfound_t = "Reset code not found",
 reset_code_nfound_b = "There is no active password reset code for specified account. The code is only active for 24 hours after generation. Check if the account ID in the box above has been typed properly or if the code was generated within 24 hours.",
 reset_code_ncorr_t = "Reset code is not correct",
 reset_code_ncorr_b = "Provided reset code isn't correct. Check if the code has been copied or typed correctly.",
 reset_pass_mod_t = "Reset the password",
 reset_pass_mod_b = "Provided reset code is valid. You can now set the new password in the form below.",
 reset_pass_mod_bttn = "Confirm new password",
 reset_pass_mod_nv1 = "Password is not valid. Valid password must consists of 8~25 alphanumeric characters",
 reset_pass_mod_nv2 = "Entered passwords are not identical. Try again.",
 reset_pass_mod_succ ="Password changed succesfully. You can use it to log-in to your account.",
 #register
 reg_mod_err1_t = "User ID non-unique",
 reg_mod_err1_b = "There is a user with that ID in our database. If you have already made an account, try to log-in or reset your password. If you haven't, then please use another user ID.",
 reg_mod_err2_t = "User ID non-valid",
 reg_mod_err2_b = "User ID is not valid. User ID must consist of 8~25 aphanumeric characters.",
 reg_mod_err3_t = "E-mail not valid",
 reg_mod_err3_b = "Provided e-mail address isn't valid. Please check if it is correctly typed.",
 reg_mod_err4_t = "Non-valid password",
 reg_mod_err4_b = "Password is not valid. It must consist of 8~25 aphanumeric characters.",
 reg_mod_err5_t = "Passwords don't match",
 reg_mod_err5_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
 reg_mod_succ_t = "User registered",
 reg_mod_succ_b = "User has been registered succesfully. You should receive an e-mail at the address you provided confirming your registration.",
  ### mail labels ###
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
 logout_modal_title = "Do you really want to log out?",
 logout_unaccept_bttn = "Don't log me out!",
 logout_impossible_modal = "You aren't logged in yet!"
)

pkgEnv$label_pl = list(
  ### UI labels ###
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
  ### modal labels ###
  # login
 id_nfound_t = "Nie znaleziono u\u017Cytkownika",
 id_nfound_1 = "Je\u017Celi konto zosta\u0142o za\u0142o\u017Cone, prosze sprawdzi\u0107 poprawno\u015B\u0107 wprowadzonej nazwy u\u017Cytkownika",
 id_nfound_2 = "Je\u017Celi jeszcze nie utworzono konta, prosz\u0119 si\u0119 zarejestrowa\u0107.",
 login_wrong_pass_t = "Nieprawid\u0142owe has\u0142o",
 login_wrong_pass_b = "Wprowadzone has\u0142o jest inne ni\u017C powi\u0105zane z nazw\u0105 u\u017Cytkownika. Spr\u00F3buj wprowadzi\u0107 je ponownie lub zresetowa\u0107 has\u0142o.",
 login_succ_t = "Zalogowano u\u017Cytkownika",
 login_succ_b = "U\u017Cytkownik zosta\u0142 poprawnie zalogowany!",
  # reset 
 id_nfound_reset = "Nie odnaleziono takiej nazwy u\u017Cytkownika w naszej bazie danych. Prosz\u0119 sprawdzi\u0107 czy nazwa zosta\u0142a wprowadzona prawid\u0142owo. Je\u017Celi konto nie zosta\u0142o wcze\u015Bniej utworzone, prosz\u0119 je najpierw zarejestrowa\u0107.",
 reset_code_send_t = "Kod resetuj\u0105cy zosta\u0142 wys\u0142any",
 reset_code_send_b = "Kod resetuj\u0105cy zosta\u0142 wys\u0142any na adres e-mail podany podczas rejestracji. B\u0119dzie aktywny przez 24h i przez ten czas mo\u017Cna go u\u017Cy\u0107 do zresetowania has\u0142a.",
 reset_code_nfound_t = "Nie odnaleziono kodu resetuj\u0105cego",
 reset_code_nfound_b = "Nie odnaleziono aktywnego kodu resetuj\u0105cego has\u0142o dla okre\u015Blonego has\u0142a. Utworzony kod jest aktywny jedynie przez 24 godziny. Prosz\u0119 sprawdzi\u0107, czy nazwa u\u017Cytkownika zosta\u0142a wpisana poprawnie w polu powy\u017Cej oraz czy kod zosta\u0142 wygenerowany w ci\u0105gu ostatnic 24 godzin.",
 reset_code_ncorr_t = "Wpisany kod jest niepoprawny",
 reset_code_ncorr_b = "Wpisany kod resetuj\u0105cy nie jest poprawny. Sprawd\u017A czy zosta\u0142 on skopiowany lub wpisany odpowiednio.",
 reset_pass_mod_t = "Zresetuj has\u0142o",
 reset_pass_mod_b = "Wprowadzony kod resetuj\u0105cy jest poprawny. Mo\u017Cesz teraz ustawi\u0107 nowe has\u0142o korzystaj\u0105c z poni\u017Cszego formularza.",
 reset_pass_mod_bttn = "Potwierd\u017A nowe has\u0142o",
 reset_pass_mod_nv1 = "Has\u0142o jest nieprawid\u0142owe. Prawid\u0142owe has\u0142o musi sk\u0142ada\u0107 si\u0119 z 8~25 liter i/lub cyfr",
 reset_pass_mod_nv2 = "Podane has\u0142a nie s\u0105 identyczne. Spr\u00F3buj ponownie.",
 reset_pass_mod_succ = "Has\u0142o poprawnie zmienione. Mo\u017Cesz u\u017Cy\u0107 go, aby zalogowa\u0107 si\u0119 na zwoje konto.",
  # register
 reg_mod_err1_t = "Istniej\u0105ca nazwa u\u017Cytkownika",
 reg_mod_err1_b = "Istnieje ju\u017C u\u017Cytkownik o takiej nazwie. Je\u017Celi stworzono wcze\u015Bniej konto, prosz\u0119 spr\u00F3bowa\u0107 si\u0119 zalogowa\u0107 lub zresetowa\u0107 has\u0142o. Je\u017Celi nie tworzono wcze\u015Bniej konta, prosz\u0119 u\u017Cy\u0107 innej nazwy u\u017Cytkownika",
 reg_mod_err2_t = "Nieprawid\u0142owa nazwa u\u017Cytkownika",
 reg_mod_err2_b = "Nazwa u\u017Cytkownika jest nieprawid\u0142owa. Powinna sk\u0142ada\u0107 si\u0119 z 8~25 liter i/lub cyfr.",
 reg_mod_err3_t = "Niepoprawny adres e-mail",
 reg_mod_err3_b = "Adres e-mail nie jest poprawny. Prosz\u0119 sprawdzi\u0107, czy zosta\u0142 dobrze wpisany.",
 reg_mod_err4_t = "Nieprawid\u0142owe has\u0142o",
 reg_mod_err4_b = "Has\u0142o jest nieprawid\u0142owe. Powinna sk\u0142ada\u0107 si\u0119 z 8~25 liter i/lub cyfr.",
 reg_mod_err5_t = "Has\u0142a nie s\u0105 identyczne",
 reg_mod_err5_b = "Wpisane has\u0142a nie s\u0105 identyczne. Powt\u00F3rzone has\u0142o musi by\u0107 dok\u0142adnie takie samo jak pierwsze.",
 reg_mod_succ_t = "Zarejestrowano u\u017Cytkownika",
 reg_mod_succ_b = "U\u017Cytkownik zosta\u0142 zarejestrowany. Na podany podczas rejestracji adres e-mail powinna dotrze\u0107 wiadomo\u015B\u0107 potwierdzaj\u0105ca rejestracj\u0119.",
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
 logout_modal_title = "Czy na pewno chcesz si\u0119 wylogowa\u0107?",
 logout_unaccept_bttn = "Nie wylogowuj!",
 logout_impossible_modal = "Nie jeste\u015B jeszcze zalogowany."
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

