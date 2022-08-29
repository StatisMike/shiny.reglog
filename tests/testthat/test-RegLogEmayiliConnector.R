test_file <- tempfile(fileext = ".txt")

writeLines("This is test attachement", test_file)

test_attachment <- mailMessageAttachment(
  filepath = test_file,
  filename = "test.txt"
)

custom_emails <- list(
  register = list(
    subject = "Custom register mail",
    body = "<p>This is custom register email. You are ?username?.</p>"
  )
)

server <- function(input, output, session) {
  
  mailConnector <- RegLogEmayiliConnector$new(
    from = "statismike@gmail.com",
    smtp = if (identical(Sys.getenv("NOT_CRAN"), "true")) { 
      emayili::gmail(
      username = "statismike@gmail.com",
      password = Sys.getenv("STATISMIKE_GMAIL_PASS"))
      } else { emayili::smtpbucket() }, 
    custom_mails = custom_emails
  )
}

recovered_message <- NULL
recovered_mails <- NULL

testServer(server, {
  
  mailConnector$listener(
    RegLogConnectorMessage(
      type = "custom_mail",
      process = "testing_mail",
      email = "statismike@gmail.com",
      mail_subject = "Custom email",
      mail_body = "<p>This email was sent by mailConnector using its <i>custom mail</i>
                 handler.</p><p>It also contains an attachement!</p>",
      mail_attachment = test_attachment
    )
  )
  
  session$elapse(5000)
  
  recovered_message <<- mailConnector$message()
  recovered_mails <<- mailConnector$mails
  
})

test_that("Custom mail have been tried to sent", {
  
  expect_equal(recovered_message$type, "custom_mail")
  
})

test_that("Custom mail body and body is attached", {
  
  expect_equal(recovered_mails$register$body,
               custom_emails$register$body)
  
  expect_equal(recovered_mails$register$subject,
               custom_emails$register$subject)
  
})

testServer(server, {
  
  mailConnector$listener(
    RegLogConnectorMessage(
      type = "reglog_mail",
      process = "register",
      username = "statismike",
      email = "statismike@gmail.com",
      app_name = "Test App",
      app_address = "http://test_reglog.app"
    )
  )
  
  session$elapse(5000)
  
  recovered_message <<- mailConnector$message()
  recovered_mails <<- mailConnector$mails
  
})

test_that("Register mail have been tried to sent", {
  
  expect_equal(recovered_message$type, "reglog_mail")
  expect_equal(recovered_message$data$process, "register")
  
})

testServer(server, {
  
  mailConnector$listener(
    RegLogConnectorMessage(
      type = "reglog_mail",
      process = "resetPass",
      username = "statismike",
      email = "statismike@gmail.com",
      app_name = "Test App",
      app_address = "http://test_reglog.app",
      reset_code = "123423"
    )
  )
  
  session$elapse(5000)
  
  recovered_message <<- mailConnector$message()
  recovered_mails <<- mailConnector$mails
  
})

test_that("Reset code mail have been tried to sent", {
  
  expect_equal(recovered_message$type, "reglog_mail")
  expect_equal(recovered_message$data$process, "resetPass")
  
})
