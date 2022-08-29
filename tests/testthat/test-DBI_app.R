## Invalid inputs
non_valid_username <- c(
  "reg",
  "reglogtoolongnamebybignumberasonlyupto30aresupported",
  "reg_log_testing",
  "reg log testing"
)

non_valid_mails <- c(
  "reg@wrong",
  "@wrong.com",
  "i am faulty@too.com",
  "what,am`doing@heh.com"
)

non_valid_pass <- c(
  "2Shrt!",
  "ThisPassWord123.IsJustSooMuch_Too_Long_For_My_Own_Goodness",
  "IAmTooWeakOfPass",
  "I Have Bad Characters"
)

# initialize ShinyApp ####

app <- AppDriver$new(
  system.file("examples", "SQLite_app", package = "shiny.reglog")
)

## new account register checks ####

test_that("Cannot register with missing input", {
  
  for (i in 1:4) {
    
    reg_inputs <- c("RegLog",
                    "reglog@test.com",
                    "regLogTest1",
                    "regLogTest1")
    
    reg_inputs[i] <- as.character(NA)
    
    app$set_inputs(`login_system-register_user_ID` = reg_inputs[1], wait_ = FALSE)
    app$set_inputs(`login_system-register_email` = reg_inputs[2], wait_ = FALSE)
    app$set_inputs(`login_system-register_pass1` = reg_inputs[3], wait_ = FALSE)
    app$set_inputs(`login_system-register_pass2` = reg_inputs[4], wait_ = FALSE)
    
    app$click("login_system-register_bttn")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "register_front")
    expect_equal(vals$data, list(success = FALSE,
                                 input_provided = FALSE))
    
  }
})

test_that("Cannot register with faulty user id", {
  
  user_ids <- c(
    "reg",
    "reglogtoolongnamebybignumberasonlyupto30aresupported",
    "reg_log_testing",
    "reg log testing"
  )
  
  reg_inputs <- c(mail = "reglog@test.com",
                  pass1 = "regLogTest1",
                  pass2 = "regLogTest1")
  
  for (i in length(user_ids)) {
    
    app$set_inputs(`login_system-register_user_ID` = user_ids[[i]])
    app$set_inputs(`login_system-register_email` = reg_inputs[["mail"]], wait_ = FALSE)
    app$set_inputs(`login_system-register_pass1` = reg_inputs[["pass1"]], wait_ = FALSE)
    app$set_inputs(`login_system-register_pass2` = reg_inputs[["pass2"]], wait_ = FALSE)
    
    app$click("login_system-register_bttn")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "register_front")
    expect_equal(vals$data, list(success = FALSE,
                                 input_provided = TRUE,
                                 valid_id = FALSE,
                                 valid_email = TRUE,
                                 valid_pass = TRUE,
                                 identical_pass = TRUE))
    
  }
})

test_that("Cannot register with faulty email", {
  
  user_emails <- c(
    "reg@wrong",
    "@wrong.com",
    "i am faulty@too.com",
    "what,am`doing@heh.com"
  )
  
  reg_inputs <- c(user_id = "RegLogTesting",
                  pass1 = "regLogTest1",
                  pass2 = "regLogTest1")
  
  for (i in length(user_emails)) {
    
    app$set_inputs(`login_system-register_user_ID` = reg_inputs[["user_id"]], wait_ = FALSE)
    app$set_inputs(`login_system-register_email` = user_emails[[i]])
    app$set_inputs(`login_system-register_pass1` = reg_inputs[["pass1"]], wait_ = FALSE)
    app$set_inputs(`login_system-register_pass2` = reg_inputs[["pass2"]], wait_ = FALSE)
    
    app$click("login_system-register_bttn")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "register_front")
    expect_equal(vals$data, list(success = FALSE,
                                 input_provided = TRUE,
                                 valid_id = TRUE,
                                 valid_email = FALSE,
                                 valid_pass = TRUE,
                                 identical_pass = TRUE))
    
  }
})

test_that("Cannot register with faulty password", {
  
  reg_inputs <- c(user_id = "RegLogTesting",
                  mail = "reglog@test.com")
  
  for (i in length(non_valid_pass)) {
    
    app$set_inputs(`login_system-register_user_ID` = reg_inputs[["user_id"]], wait_ = FALSE)
    app$set_inputs(`login_system-register_email` = reg_inputs[["mail"]], wait_ = FALSE)
    app$set_inputs(`login_system-register_pass1` = non_valid_pass[[i]])
    app$set_inputs(`login_system-register_pass2` = non_valid_pass[[i]])
    
    app$click("login_system-register_bttn")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "register_front")
    expect_equal(vals$data, list(success = FALSE,
                                 input_provided = TRUE,
                                 valid_id = TRUE,
                                 valid_email = TRUE,
                                 valid_pass = FALSE,
                                 identical_pass = TRUE))
    
  }
})

test_that("Cannot register with non-identical passwords", {
  
  reg_inputs <- c(user_id = "RegLogTesting",
                  mail = "reglog@test.com",
                  pass1 = "regLogTest1",
                  pass2 = "anotherPass1")
  
  app$set_inputs(`login_system-register_user_ID` = reg_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_email` = reg_inputs[["mail"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_pass1` = reg_inputs[["pass1"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_pass2` = reg_inputs[["pass2"]], wait_ = FALSE)
  
  app$click("login_system-register_bttn")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "register_front")
  expect_equal(vals$data, list(success = FALSE,
                               input_provided = TRUE,
                               valid_id = TRUE,
                               valid_email = TRUE,
                               valid_pass = TRUE,
                               identical_pass = FALSE))
})

test_that("Can register with correct inputs", {
  
  reg_inputs <- c(user_id = "RegLogTesting",
                  mail = "reglog@test.com",
                  pass1 = "regLogTest1",
                  pass2 = "regLogTest1")
  
  app$set_inputs(`login_system-register_user_ID` = reg_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_email` = reg_inputs[["mail"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_pass1` = reg_inputs[["pass1"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_pass2` = reg_inputs[["pass2"]], wait_ = FALSE)
  
  app$click("login_system-register_bttn")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "register")
  expect_equal(vals$data, list(success = TRUE,
                               username = TRUE,
                               email = TRUE,
                               user_id = reg_inputs[["user_id"]],
                               user_mail = reg_inputs[["mail"]]))
  
})

test_that("Cannot register with conflicts", {
  
  reg_inputs <- c(user_id = "RegLogTesting",
                  user_id2 = "RegLogTesting2",
                  mail = "reglog@test.com",
                  mail2 = "reglog2@test.com",
                  pass1 = "regLogTest1",
                  pass2 = "regLogTest1")
  
  app$set_inputs(`login_system-register_user_ID` = reg_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_email` = reg_inputs[["mail2"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_pass1` = reg_inputs[["pass1"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_pass2` = reg_inputs[["pass2"]], wait_ = FALSE)
  
  app$click("login_system-register_bttn")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "register")
  expect_equal(vals$data, list(success = FALSE,
                               username = FALSE,
                               email = TRUE))
  
  app$set_inputs(`login_system-register_user_ID` = reg_inputs[["user_id2"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_email` = reg_inputs[["mail"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_pass1` = reg_inputs[["pass1"]], wait_ = FALSE)
  app$set_inputs(`login_system-register_pass2` = reg_inputs[["pass2"]], wait_ = FALSE)
  
  app$click("login_system-register_bttn")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "register")
  expect_equal(vals$data, list(success = FALSE,
                               username = TRUE,
                               email = FALSE))
  
})

# change tab
app$set_inputs("reglogtabset" = "Login")

## login checks ####

test_that("Cannot login with missing input", {
  
  for (i in 1:2) {
    
    log_inputs <- c(user_id = "RegLogTesting",
                    pass = "regLogTest1")
    
    log_inputs[[i]] <- as.character(NA)
    
    app$set_inputs(`login_system-login_user_id` = log_inputs[[1]], wait_ = FALSE)
    app$set_inputs(`login_system-password_login` = log_inputs[[2]], wait_ = FALSE)
    
    app$click("login_system-login_button")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "login_front")
    expect_equal(vals$data, list(success = FALSE,
                                 input_provided = FALSE))
    
  }
  
})

test_that("Cannot login with bad username", {
  
  log_inputs <- c(user_id = "RegLogBad",
                  pass = "regLogTest1")
  
  app$set_inputs(`login_system-login_user_id` = log_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-password_login` = log_inputs[["pass"]], wait_ = FALSE)
  
  app$click("login_system-login_button")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "login")
  expect_equal(vals$data, list(success = FALSE,
                               username = FALSE,
                               password = FALSE))
  
})

test_that("Cannot login with bad password", {
  
  log_inputs <- c(user_id = "RegLogTesting",
                  pass = "regLogBadPass")
  
  app$set_inputs(`login_system-login_user_id` = log_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-password_login` = log_inputs[["pass"]], wait_ = FALSE)
  
  app$click("login_system-login_button")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "login")
  expect_equal(vals$data, list(success = FALSE,
                               username = TRUE,
                               password = FALSE))
  
})

test_that("Can login with correct credentials", {
  
  log_inputs <- c(user_id = "RegLogTesting",
                  pass = "regLogTest1")
  
  app$set_inputs(`login_system-login_user_id` = log_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-password_login` = log_inputs[["pass"]], wait_ = FALSE)
  
  app$click("login_system-login_button")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "login")
  expect_equal(vals$data, list(success = TRUE,
                               username = TRUE,
                               password = TRUE,
                               user_id = log_inputs[["user_id"]],
                               user_mail = "reglog@test.com",
                               account_id = 1))
  
  expect_true(app$get_value(export = "is_logged"))
  
})

## logout checks ####

test_that("Can logout when logged in", {
  
  app$click("logout")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "logout")
  expect_equal(vals$data, list(success = TRUE))
  
  expect_false(app$get_value(export = "is_logged"))
  
})

test_that("Cannot logout when not logged in", {
  
  app$click("logout")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "logout")
  expect_equal(vals$data, list(success = FALSE))
  
})

# change tab
app$set_inputs("reglogtabset" = "Password reset")

## reset pass checks ####
reset_code <- NULL

test_that("Cannot generate resetpass code without ID", {
  
  app$set_inputs(`login_system-reset_user_ID` = "", wait_ = FALSE)
  
  app$click("login_system-reset_send")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "resetPass_front")
  expect_equal(vals$data, list(success = FALSE,
                               step = "generate",
                               input_provided = FALSE))
  
})

test_that("Cannot generate resetpass code with bad ID", {
  
  app$set_inputs(`login_system-reset_user_ID` = "RegLogBad")
  
  app$click("login_system-reset_send")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "resetPass_generate")
  expect_equal(vals$data, list(success = FALSE))
  
})

test_that("Can generate reset pass code", {
  
  app$set_inputs(`login_system-reset_user_ID` = "RegLogTesting")
  
  app$click("login_system-reset_send")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  reset_code <<- vals$data$reset_code
  
  expect_equal(vals$type, "resetPass_generate")
  expect_equal(vals$data, list(success = TRUE,
                               user_id = "RegLogTesting",
                               user_mail = "reglog@test.com",
                               reset_code = reset_code))
  
})

test_that("Cannot reset password without all inputs", {
  
  for (i in 1:4) {
    
    resetpass_inputs <- c("RegLogTesting",
                          reset_code,
                          "regLogTest2",
                          "regLogTest2")
    
    resetpass_inputs[i] <- as.character(NA)
    
    app$set_inputs(`login_system-reset_user_ID` = resetpass_inputs[1], wait_ = FALSE)
    app$set_inputs(`login_system-reset_code` = resetpass_inputs[2], wait_ = FALSE)
    app$set_inputs(`login_system-reset_pass1` = resetpass_inputs[3], wait_ = FALSE)
    app$set_inputs(`login_system-reset_pass2` = resetpass_inputs[4], wait_ = FALSE)
    
    app$click("login_system-reset_confirm_bttn")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "resetPass_front")
    expect_equal(vals$data, list(success = FALSE,
                                 step = "confirm",
                                 input_provided = FALSE))
    
  }
  
})

test_that("Cannot reset password with not-valid passwords", {
  
  for (i in length(non_valid_pass)) {
    
    resetpass_inputs <- c(user_id = "RegLogTesting",
                          reset_code = reset_code,
                          pass1 = non_valid_pass[i],
                          pass2 = non_valid_pass[i])
    
    app$set_inputs(`login_system-reset_user_ID` = resetpass_inputs[["user_id"]], wait_ = FALSE)
    app$set_inputs(`login_system-reset_code` = resetpass_inputs[["reset_code"]], wait_ = FALSE)
    app$set_inputs(`login_system-reset_pass1` = resetpass_inputs[["pass1"]], wait_ = FALSE)
    app$set_inputs(`login_system-reset_pass2` = resetpass_inputs[["pass2"]], wait_ = FALSE)
    
    app$click("login_system-reset_confirm_bttn")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "resetPass_front")
    expect_equal(vals$data, list(success = FALSE,
                                 step = "confirm",
                                 input_provided = TRUE,
                                 valid_pass = FALSE,
                                 identical_pass = TRUE))
  }
})

test_that("Cannot reset password with different passwords", {
  
  resetpass_inputs <- c(user_id = "RegLogTesting",
                        reset_code = reset_code,
                        pass1 = "regLogTest2",
                        pass2 = "regLogTest3")
  
  app$set_inputs(`login_system-reset_user_ID` = resetpass_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_code` = resetpass_inputs[["reset_code"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_pass1` = resetpass_inputs[["pass1"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_pass2` = resetpass_inputs[["pass2"]], wait_ = FALSE)
  
  app$click("login_system-reset_confirm_bttn")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "resetPass_front")
  expect_equal(vals$data, list(success = FALSE,
                               step = "confirm",
                               input_provided = TRUE,
                               valid_pass = TRUE,
                               identical_pass = FALSE))
  
})

test_that("Cannot reset password with bad ID", {
  
  resetpass_inputs <- c(user_id = "RegLogBad",
                        reset_code = reset_code,
                        pass1 = "regLogTest2",
                        pass2 = "regLogTest2")
  
  app$set_inputs(`login_system-reset_user_ID` = resetpass_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_code` = resetpass_inputs[["reset_code"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_pass1` = resetpass_inputs[["pass1"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_pass2` = resetpass_inputs[["pass2"]], wait_ = FALSE)
  
  app$click("login_system-reset_confirm_bttn")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "resetPass_confirm")
  expect_equal(vals$data, list(success = FALSE,
                               username = FALSE,
                               code_valid = FALSE))
  
})

test_that("Cannot reset password with bad code", {
  
  resetpass_inputs <- c(user_id = "RegLogTesting",
                        reset_code = ceiling(as.numeric(reset_code) / 2),
                        pass1 = "regLogTest2",
                        pass2 = "regLogTest2")
  
  app$set_inputs(`login_system-reset_user_ID` = resetpass_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_code` = resetpass_inputs[["reset_code"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_pass1` = resetpass_inputs[["pass1"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_pass2` = resetpass_inputs[["pass2"]], wait_ = FALSE)
  
  app$click("login_system-reset_confirm_bttn")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "resetPass_confirm")
  expect_equal(vals$data, list(success = FALSE,
                               username = TRUE,
                               code_valid = FALSE))
  
})

test_that("Password reset can be made", {
  
  resetpass_inputs <- c(user_id = "RegLogTesting",
                        reset_code = reset_code,
                        pass1 = "regLogTest2",
                        pass2 = "regLogTest2")
  
  app$set_inputs(`login_system-reset_user_ID` = resetpass_inputs[["user_id"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_code` = resetpass_inputs[["reset_code"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_pass1` = resetpass_inputs[["pass1"]], wait_ = FALSE)
  app$set_inputs(`login_system-reset_pass2` = resetpass_inputs[["pass2"]], wait_ = FALSE)
  
  app$click("login_system-reset_confirm_bttn")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "resetPass_confirm")
  expect_equal(vals$data, list(success = TRUE,
                               username = TRUE,
                               code_valid = TRUE))
  
})

test_that("Can login with changed password", {
  
  app$set_inputs("reglogtabset" = "Login")
  
  app$set_inputs(`login_system-login_user_id` = "RegLogTesting", wait_ = FALSE)
  app$set_inputs(`login_system-password_login` = "regLogTest2", wait_ = FALSE)
  
  app$click("login_system-login_button")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "login")
  expect_equal(vals$data, list(success = TRUE,
                               username = TRUE,
                               password = TRUE,
                               user_id = "RegLogTesting",
                               user_mail = "reglog@test.com",
                               account_id = 1))
  
  expect_true(app$get_value(export = "is_logged"))
  
})

# switch tab

app$set_inputs("reglogtabset" = "Credentials edit")

## credentials edit checks ####

test_that("Cannot change password without inputs", {
  
  for (i in 1:3) {
    
    crededit_inputs <- c("regLogTest2",
                         "regLogTest3",
                         "regLogTest3")
    
    crededit_inputs[i] <- as.character(NA)
    
    app$set_inputs(`login_system-cred_edit_old_pass` = crededit_inputs[1], wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_pass1` = crededit_inputs[2], wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_pass2` = crededit_inputs[3], wait_ = FALSE)
    
    app$click("login_system-cred_edit_pass_change")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "credsEdit_front")
    expect_equal(vals$data, list(success = FALSE,
                                 user_logged = TRUE,
                                 input_provided = FALSE,
                                 change = "pass"))
    
    app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_pass1` = "", wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_pass2` = "", wait_ = FALSE)
    
  }
})

test_that("Cannot change user ID without inputs", {
  
  for (i in 1:2) {
    
    crededit_inputs <- c("regLogTest2",
                         "regLogTesting2")
    
    crededit_inputs[i] <- as.character(NA)
    
    app$set_inputs(`login_system-cred_edit_old_pass` = crededit_inputs[1], wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_ID` = crededit_inputs[2], wait_ = FALSE)
    
    app$click("login_system-cred_edit_other_change")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "credsEdit_front")
    expect_equal(vals$data, list(success = FALSE,
                                 user_logged = TRUE,
                                 input_provided = FALSE,
                                 change = "other"))
    
    app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_ID` = "", wait_ = FALSE)
    
  }
})

test_that("Cannot change user mail without inputs", {
  
  for (i in 1:2) {
    
    crededit_inputs <- c("regLogTest2",
                         "reglog2@test.com")
    
    crededit_inputs[i] <- as.character(NA)
    
    app$set_inputs(`login_system-cred_edit_old_pass` = crededit_inputs[1], wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_mail` = crededit_inputs[2], wait_ = FALSE)
    
    app$click("login_system-cred_edit_other_change")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "credsEdit_front")
    expect_equal(vals$data, list(success = FALSE,
                                 user_logged = TRUE,
                                 input_provided = FALSE,
                                 change = "other"))
  }
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_mail` = "", wait_ = FALSE)
  
})

test_that("Cannot set invalid password during change", {
  
  for (i in length(non_valid_pass)) {
    
    app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest2", wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_pass1` = non_valid_pass[i], wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_pass2` = non_valid_pass[i], wait_ = FALSE)
    
    app$click("login_system-cred_edit_pass_change")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "credsEdit_front")
    expect_equal(vals$data, list(success = FALSE,
                                 user_logged = TRUE,
                                 input_provided = TRUE,
                                 change = "pass",
                                 valid_pass = FALSE,
                                 identical_pass = TRUE))
    
  }
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass1` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass2` = "", wait_ = FALSE)
})

test_that("Cannot set invalid user ID during change", {
  
  for (i in length(non_valid_username)) {
    
    app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest2", wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_ID` = non_valid_username[i], wait_ = FALSE)
    
    app$click("login_system-cred_edit_other_change")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "credsEdit_front")
    expect_equal(vals$data, list(success = FALSE,
                                 user_logged = TRUE,
                                 input_provided = TRUE,
                                 change = "other",
                                 valid_id = FALSE,
                                 valid_email = NULL))
    
  }
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_ID` = "", wait_ = FALSE)
})

test_that("Cannot set invalid email during change", {
  
  for (i in length(non_valid_mails)) {
    
    app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest2", wait_ = FALSE)
    app$set_inputs(`login_system-cred_edit_new_mail` = non_valid_mails[i], wait_ = FALSE)
    
    app$click("login_system-cred_edit_other_change")
    
    
    
    vals <- app$get_value(export = "RegLogMessage")
    
    expect_equal(vals$type, "credsEdit_front")
    expect_equal(vals$data, list(success = FALSE,
                                 user_logged = TRUE,
                                 input_provided = TRUE,
                                 change = "other",
                                 valid_id = NULL,
                                 valid_email = FALSE))
    
  }
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_mail` = "", wait_ = FALSE)
  
})

test_that("Cannot change credentials with bad password", {
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "regLogBadPass", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_ID` = "RegLogTesting2", wait_ = FALSE)
  
  app$click("login_system-cred_edit_other_change")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "credsEdit")
  expect_equal(vals$data, list(success = FALSE,
                               password = FALSE))
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_mail` = "", wait_ = FALSE)
  
})

test_that("Cannot change user ID to existing one", {
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest2", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_ID` = "RegLogTesting", wait_ = FALSE)
  
  app$click("login_system-cred_edit_other_change")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "credsEdit")
  expect_equal(vals$data, list(success = FALSE,
                               password = TRUE,
                               new_username = FALSE,
                               new_email = TRUE))
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_ID` = "", wait_ = FALSE)
})

test_that("Cannot change user email to existing one", {
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest2", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_mail` = "reglog@test.com", wait_ = FALSE)
  
  app$click("login_system-cred_edit_other_change")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "credsEdit")
  expect_equal(vals$data, list(success = FALSE,
                               password = TRUE,
                               new_username = TRUE,
                               new_email = FALSE))
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_mail` = "", wait_ = FALSE)
})

test_that("Can change password", {
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest2", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass1` = "regLogTest3", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass2` = "regLogTest3", wait_ = FALSE)
  
  app$click("login_system-cred_edit_pass_change")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  
  expect_equal(vals$type, "credsEdit")
  expect_equal(vals$data, list(success = TRUE,
                               password = TRUE,
                               new_user_id = NULL,
                               new_user_mail = NULL,
                               new_user_pass = TRUE))
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass1` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass2` = "", wait_ = FALSE)
  
})

test_that("Can change user ID", {
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest3", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_ID` = "RegLogTesting2", wait_ = FALSE)
  
  app$click("login_system-cred_edit_other_change")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  
  expect_equal(vals$type, "credsEdit")
  expect_equal(vals$data, list(success = TRUE,
                               password = TRUE,
                               new_user_id = "RegLogTesting2",
                               new_user_mail = NULL,
                               new_user_pass = NULL))
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_ID` = "", wait_ = FALSE)
  
})

test_that("Can change user email", {
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest3", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_mail` = "reglog3@test.com", wait_ = FALSE)
  
  app$click("login_system-cred_edit_other_change")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  
  expect_equal(vals$type, "credsEdit")
  expect_equal(vals$data, list(success = TRUE,
                               password = TRUE,
                               new_user_id = NULL,
                               new_user_mail = "reglog3@test.com",
                               new_user_pass = NULL))
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_mail` = "", wait_ = FALSE)
  
})

# Logout

app$click("logout")

test_that("Not logged user cannot change password", {
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass1` = "regLogTest2", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass2` = "regLogTest2", wait_ = FALSE)
  
  app$click("login_system-cred_edit_pass_change")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "credsEdit_front")
  expect_equal(vals$data, list(success = FALSE,
                               user_logged = FALSE,
                               change = "pass"))
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass1` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_pass2` = "", wait_ = FALSE)
  
})

test_that("Not logged user cannot change user ID", {
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "regLogTest2", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_ID` = "RegLogTesting", wait_ = FALSE)
  
  app$click("login_system-cred_edit_other_change")
  
  
  
  vals <- app$get_value(export = "RegLogMessage")
  
  expect_equal(vals$type, "credsEdit_front")
  expect_equal(vals$data, list(success = FALSE,
                               user_logged = FALSE,
                               change = "other"))
  
  app$set_inputs(`login_system-cred_edit_old_pass` = "", wait_ = FALSE)
  app$set_inputs(`login_system-cred_edit_new_ID` = "", wait_ = FALSE)
  
})

## Logs test ####

test_that("Logs can be read from database", {
  
  app$click("logs")
  
  logs <- app$get_value(export = "logs")
  
  expect_s3_class(logs, "data.frame")
  expect_equal(names(logs),
               c("direction", "time", "session", "type", "note"))
  expect_equal(unique(logs$direction),
               c("received", "sent"))
  
})

app_wait(app)

app$stop()
