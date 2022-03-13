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
  reset_ui_3 = "After receiving a reset e-mail, enter the code in the box below and press the 'Confirm code' button. The reset code will be active for 4 hours.",
  reset_ui_4 = "Received code",
  reset_bttn_1 = "Send code",
  reset_bttn_2 = "Confirm code",
  ### register module specific labels ####
  register_ui_1 = "Registration form",
  register_ui_2 = "In the form below you can register a new account. Choose a user ID, provide a valid e-mail adress and choose a password for your account.",
  register_ui_3 = "User ID and password should consist of 8~30 characters. For user ID every alphanumeric characters are valid. Password should contain at least three out of four following types of characters: big letter, small letter, number, special character.",
  register_ui_4 = "You should have access to the provided e-mail address. After registration you will receive a confirmation e-mail. Moreover, if you ever forget your password you can reset it with reset code send to provided e-mail.",
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
  register_nonValidId_b = "User ID is not valid. User ID must consist of 8~30 aphanumeric characters.",
  register_nonValidEmail_t = "E-mail not valid",
  register_nonValidEmail_b = "Provided e-mail address isn't valid. Please check if it is correctly typed.",
  register_nonValidPass_t = "Non-valid password",
  register_nonValidPass_b = "Provided password isn't valid. Password must consist of 8~30 characters. It should also contain at least three out of four following types of characters: big letter, small letter, number, special character.",
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
  credsEdit_nonValidId_b = "Provided new user ID isn't valid. User ID must consist of 8~30 alphanumeric characters.",
  credsEdit_nonValidPass_t = "Non-valid password",
  credsEdit_nonValidPass_b = "Provided new password isn't valid. Password must consist of 8~30 characters. It should also contain at least three out of four following types of characters: big letter, small letter, number, special character.",
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
  resetPass_nonValidPass_b = "Provided new password isn't valid. Password must consist of 8~30 characters. It should also contain at least three out of four following types of characters: big letter, small letter, number, special character.",
  resetPass_notIdenticalPass_t = "Passwords don't match.",
  resetPass_notIdenticalPass_b = "Provided passwords don't match. Repeated password must be exactly the same as the first one.",
  resetPass_badId_t = "User ID not found",
  resetPass_badId_b = "Provided user ID isn't found in our database.",
  resetPass_invalidCode_t = "Incorrect reset code",
  resetPass_invalidCode_b = "Provided reset code isn't correct. Check if the code has been copied or typed in correctly.",
  resetPass_codeGenerated_t = "Code generated successfully!",
  resetPass_codeGenerated_b = "Reset code has been generated and sent to your e-mail. It will be valid for 4 hours.",
  resetPass_success_t = "Password changed successfully!",
  resetPass_success_b = "Password has been changed. You can now log in used your new password.",
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
  # credentials edit
  crededit_mail_h = "data edit confirmation",
  crededit_mail_1 = "Credentials data has been changed for user identified by user ID:",
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
  reset_ui_3 = "Po otrzymaniu wiadomo\u015Bci wprowad\u017A otrzymany kod w pole poni\u017Cej i wci\u015Bnij przycisk 'Potwierd\u017A kod'. Kod b\u0119dzie aktywny przez 4 godziny.",
  reset_ui_4 = "Otrzymany kod",
  reset_bttn_1 = "Wy\u015Blij kod",
  reset_bttn_2 = "Potwierd\u017A kod",
  # register module specific labels
  register_ui_1 = "Formularz rejestracyjny",
  register_ui_2 = "W poni\u017Cszym formularzu mo\u017Cna zarejetrowa\u0107 nowe konto. Wybierz nazw\u0119 u\u017Cytkownika, podaj poprawny adres e-mail i wybierz has\u0142o dla swojego konta.",
  register_ui_3 = "Nazwa u\u017Cytkownika i has\u0142o powinny sk\u0142ada\u0107 si\u0119 z 8~30 znak\u00F3w. Nazwa u\u017Cytkownika mo\u017Ce zawiera\u0107 litery oraz cyfry. Has\u0142o powinno zawiera\u0107 co najmniej 3 z 4 nast\u0119puj\u0105cych typ\u00F3w znak\u00F3w: ma\u0142\u0105 liter\u0119, du\u017C\u0105 liter\u0119, cyfr\u0119, znak specjalny.",
  register_ui_4 = "Podany adres e-mail powinien dla ciebie dost\u0119pny. Po rejestracji otrzymasz wiadomo\u015B\u0107 potwierdzaj\u0105c\u0105. Co wi\u0119cej, je\u017Celi kiedykolwiek zapomnisz swojego has\u0142a, mo\u017Cesz je zresetowa\u0107 poprzez kod resetujący wysłany na podany adres e-mail.",
  register_bttn = "Zarejestruj",
  ## modal texts ####
  ### login modals ####
  login_noInput_t = "Brakuj\u0105ce dane",
  login_noInput_b = "Aby si\u0119 zalogowa\u0107, prosz\u0119 poda\u0107 swoj\u0105 nazw\u0119 u\u017Cytkownika oraz has\u0142o.",
  login_success_t = "Zalogowano u\u017Cytkownika!",
  login_success_b = "Logowanie zako\u0144czono pomy\u015Blnie.",
  login_badId_t = "Nie odnaleziono u\u017Cytkownika",
  login_badId_b = "Je\u017Celi konto zosta\u0142o wcze\u015Bniej zarejestrowane, sprawd\u017A czy nazwa u\u017Cytkownika zosta\u0142a podana prawid\u0142owo. Je\u017Celi jeszcze nie utworzono konta, prosz\u0119 o zarejestrowanie.",
  login_badPass_t = "Nieprawid\u0142owe has\u0142o",
  login_badPass_b = "Podane has\u0142o nie odpowiada obecnemu w naszej bazie. Spr\u00F3buj ponownie lub zresetuj has\u0142o.",
  ### register modals ####
  register_noInput_t = "Brakuj\u0105ce dane",
  register_noInput_b = "Aby zarejestowa\u0107 konto, prosz\u0119 poda\u0107 wszystkie niezb\u0119dne dane: nazw\u0119 u\u017Cytkownika, e-mail oraz has\u0142o.",
  register_nonValidId_t = "Nieprawid\u0142owa nazwa u\u017Cytkownika",
  register_nonValidId_b = "Podana nazwa u\u017Cytkownika jest nieprawid\u0142owa. Powinna sk\u0142ada\u0107 si\u0119 z 8 do 25 liter i/lub cyfr.",
  register_nonValidEmail_t = "Nieprawid\u0142owy adres e-mail",
  register_nonValidEmail_b = "Podany adres e-mail jest nieprawid\u0142owy. Prosz\u0119 o upewnienie si\u0119, \u017Ce zosta\u0142 wprowadzony prawid\u0142owo.",
  register_nonValidPass_t = "Nieprawid\u0142owe has\u0142o",
  register_nonValidPass_b = "Has\u0142o jest nieprawid\u0142owe. Powinno sk\u0142ada\u0107 si\u0119 z 8 do 30 znak\u00F3w oraz powinno zawiera\u0107 co najmniej 3 z 4 nast\u0119puj\u0105cych typ\u00F3w znak\u00F3w: ma\u0142\u0105 liter\u0119, du\u017C\u0105 liter\u0119, cyfr\u0119, znak specjalny.",
  register_notIdenticalPass_t = "Wprowadzone has\u0142a nie s\u0105 identyczne",
  register_notIdenticalPass_b = "Wprowadzone has\u0142a si\u0119 r\u00F3\u017Cni\u0105. Has\u0142o wprowadzone w obydwu polach powinny by\u0107 jednakowe.",
  register_existingId_t = "Nazwa u\u017Cytkownika nie jest unikalna",
  register_existingId_b = "W naszej bazie istnieje ju\u017C u\u017Cytkownik o takiej nazwie. Je\u017Celi konto zosta\u0142o wcze\u015Bniej zarejestrowane, prosz\u0119 o zalogowanie lub zresetowanie has\u0142a.",
  register_existingEmail_t = "Adres e-mail nie jest unikalny",
  register_existingEmail_b = "W naszej bazie istnieje ju\u017C u\u017Cytkownik o takim adresie e-mail. Je\u017Celi utworzono ju\u017C konto, prosz\u0119 si\u0119 zalogowa\u0107 lub zresetowa\u0107 has\u0142o. Je\u017Celi konto nie zosta\u0142o jeszcze utworzone, prosz\u0119 wybra\u0107 inny adres e-mail.",
  register_success_t = "Zarejestrowano u\u017Cytkownika",
  register_success_b = "U\u017Cytkownik zosta\u0142 pomy\u015Blnie zarejestrowany. Na podany adres zosta\u0142a wys\u0142ana wiadomo\u015B\u0107 e-mail potwierdzaj\u0105ca rejestracj\u0119.",
  ### credsEdit modals ####
  credsEdit_noInput_pass_t = "Brakuj\u0105ce dane",
  credsEdit_noInput_pass_b = "Aby zmieni\u0107 has\u0142o, prosz\u0119 poda\u0107 zar\u00F3wno obecn\u0105 nazw\u0119 u\u017Cytkownika obecne has\u0142o oraz nowe has\u0142o..",
  credsEdit_noInput_other_t = "Brakuj\u0105ce dane",
  credsEdit_noInput_other_b = "Aby zmieni\u0107 nazw\u0119 u\u017Cytkownika i/lub e-mail, prosz\u0119 poda\u0107 obecn\u0105 nazw\u0119 u\u017Cytkownika i has\u0142o oraz now\u0105 nazw\u0119 u\u017Cytkownika i/lub e-mail.",
  credsEdit_badId_t = "Nie odnaleziono u\u017Cytkownika",
  credsEdit_badId_b = "Wprowadzona nazwa u\u017Cytkownika nie istnieje w naszej bazie.",
  credsEdit_badPass_t = "Nieprawid\u0142owe has\u0142o",
  credsEdit_badPass_b = "Podane has\u0142o nie odpowiada obecnemu w naszej bazie. Spr\u00F3buj ponownie lub zresetuj has\u0142o.",
  credsEdit_nonValidId_t = "Nieprawid\u0142owa nazwa u\u017Cytkownika",
  credsEdit_nonValidId_b = "Podana nazwa u\u017Cytkownika jest nieprawid\u0142owa. Powinna sk\u0142ada\u0107 si\u0119 z 8 do 30 liter i/lub cyfr.",
  credsEdit_nonValidPass_t = "Nieprawid\u0142owe has\u0142o",
  credsEdit_nonValidPass_b = "Has\u0142o jest nieprawid\u0142owe. Powinno sk\u0142ada\u0107 si\u0119 z 8 do 30 znak\u00F3w oraz powinno zawiera\u0107 co najmniej 3 z 4 nast\u0119puj\u0105cych typ\u00F3w znak\u00F3w: ma\u0142\u0105 liter\u0119, du\u017C\u0105 liter\u0119, cyfr\u0119, znak specjalny.",
  credsEdit_nonValidEmail_t = "Nieprawid\u0142owy adres e-mail",
  credsEdit_nonValidEmail_b = "Podany adres e-mail jest nieprawid\u0142owy. Prosz\u0119 o upewnienie si\u0119, \u017Ce zosta\u0142 wprowadzony prawid\u0142owo.",
  credsEdit_notIdenticalPass_t = "Wprowadzone has\u0142a nie s\u0105 identyczne",
  credsEdit_notIdenticalPass_b = "Wprowadzone has\u0142a si\u0119 r\u00F3\u017Cni\u0105. Has\u0142o wprowadzone w obydwu polach powinny by\u0107 jednakowe.",
  credsEdit_existingId_t = "Nazwa u\u017Cytkownika nie jest unikalna",
  credsEdit_existingId_b = "W naszej bazie istnieje ju\u017C u\u017Cytkownik identycznej nazwie jak podana jako nowa nazwa u\u017Cytkownika.",
  credsEdit_existingEmail_t = "Adres e-mail nie jest unikalny",
  credsEdit_existingEmail_b = "W naszej bazie istnieje ju\u017C u\u017Cytkownik o identycznym adresie jak podany jako nowy adres e-mail.",
  credsEdit_success_t = "Pomy\u015Blna edycja danych",
  credsEdit_success_b = "Dane u\u017Cytkownika zosta\u0142y pomy\u015Blnie zmienione.",
  ### resetPass modals ####
  resetPass_noInput_generate_t = "Brakuj\u0105ce dane",
  resetPass_noInput_generate_b = "Aby wygenerowa\u0107 kod resetuj\u0105cy i przes\u0142a\u0107 je na adres e-mail prosz\u0119 poda\u0107 swoj\u0105 nazw\u0119 u\u017Cytkownika.",
  resetPass_noInput_confirm_t = "Brakuj\u0105ce dane",
  resetPass_noInput_confirm_b = "Aby zresetowa\u0107 has\u0142o za pomoc\u0105 otrzymanego has\u0142a, prosz\u0119 o podanie nazwy u\u017Cytkownika, otrzymanego kodu i nowe has\u0142o.",
  resetPass_nonValidPass_t = "Nieprawid\u0142owe has\u0142o",
  resetPass_nonValidPass_b = "Has\u0142o jest nieprawid\u0142owe. Powinno sk\u0142ada\u0107 si\u0119 z 8 do 30 znak\u00F3w oraz powinno zawiera\u0107 co najmniej 3 z 4 nast\u0119puj\u0105cych typ\u00F3w znak\u00F3w: ma\u0142\u0105 liter\u0119, du\u017C\u0105 liter\u0119, cyfr\u0119, znak specjalny.",
  resetPass_notIdenticalPass_t = "Wprowadzone has\u0142a nie s\u0105 identyczne",
  resetPass_notIdenticalPass_b = "Wprowadzone has\u0142a si\u0119 r\u00F3\u017Cni\u0105. Has\u0142o wprowadzone w obydwu polach powinny by\u0107 jednakowe.",
  resetPass_badId_t = "Nie odnaleziono u\u017Cytkownika",
  resetPass_badId_b = "Wprowadzona nazwa u\u017Cytkownika nie istnieje w naszej bazie.",
  resetPass_invalidCode_t = "Nieprawid\u0142owy kod resetuj\u0105cy",
  resetPass_invalidCode_b = "Wprowadzony kod resetuj\u0105cy nie jest prawid\u0142owy. Prosz\u0119 sprawdzi\u0107, czy kod zosta\u0142 prawid\u0142owo wprowadzony.",
  resetPass_codeGenerated_t = "Kod wygenerowany pomy\u015Blnie!",
  resetPass_codeGenerated_b = "Kod resetuj\u0105cy has\u0142o zosta\u0142 wys\u0142any na tw\u00F3j adres e-mail. B\u0119dzie on wa\u017Cny przez 4 godziny.",
  resetPass_success_t = "Has\u0142o zmienione pomy\u015Blnie!",
  resetPass_success_b = "Has\u0142o zosta\u0142o zmienione. Mo\u017Cesz si\u0119 teraz zalogowa\u0107 korzystaj\u0105c z nowego has\u0142a.",
  ### logout modal ####
  logout_notLogIn_t = "Nie mo\u017Cna wylogowa\u0107",
  logout_notLogIn_b = "Nie jeste\u015B zalogowany.",
  logout_success_t = "Wylogowano",
  logout_success_b = "Wylogowano poprawnie.",
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
  # credentials edit
  crededit_mail_h = "potwierdzenie edycji danych",
  crededit_mail_1 = "Zmieniono dane u\u017Cytkownika identyfikowanego nazw\u0105:",
  # logout bttn
  logout_bttn = "Wyloguj",
  logout_mod_t = "Wylogowano",
  logout_mod_b = "Pomy\u015Blnie wylogowano!",
  # creds_edit
  cred_edit_ui_h1 = "Zmie\u0144 swoje dane",
  cred_eidt_ui_p = "Tutaj mo\u017Cesz zmieni\u0107 swoje dane. Po pomy\u015Blnej zmianie nast\u0105pi przelogowanie z wykorzystaniem zaktualizowanych danych.",
  cred_edit_ui_h2_old = "Potwierd\u017A to\u017Casamo\u015B\u0107",
  cred_edit_ui_p_old = "Przed zatwierdzeniem jakichkolwiek zmian, prosz\u0119 o potwierdzenie swojej to\u017Csamo\u015Bci z wykorzystaniem obecnej nazwy u\u017Cytkownika i has\u0142a.",
  cred_edit_ui_h2_pass_change = "Zmie\u0144 obecne has\u0142o",
  cred_edit_ui_p_pass_change = "Wpisz i potwierd\u017A nowe has\u0142o poni\u017Cej.",
  cred_edit_pass_change_bttn = "Zatwierd\u017A zmian\u0119 has\u0142a",
  cred_edit_ui_h2_other_change = "Zmie\u0144 dane u\u017Cytkownika",
  cred_edit_ui_p_other_change = "Wpisz now\u0105 nazw\u0119 u\u017Cytkownika i/lub nowy adres e-mail.",
  cred_edit_other_change_bttn = "Zatwierd\u017A zmian\u0119 danych u\u017Cytkownika"
)

# i18 'lang'

RegLog_txts$i18 <- as.list(
  setNames(
    names(shiny.reglog:::RegLog_txts$en), 
    names(shiny.reglog:::RegLog_txts$en)))

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
        return(default_txt)
      } else {
        return(custom_txt)
      }
    }
  }
}

