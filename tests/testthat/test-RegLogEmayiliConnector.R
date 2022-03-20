test_attachment <- tempfile(fileext = ".txt")

writeLines("This is test attachement", test_attachment)

custom_emails <- list(
  register = list(
    subject = "Custom register mail",
    body = "<p>This is custom register email. You are ?username?.</p>"
  )
)

server <- function(input, output, session) {
  
  mailConnector <- RegLogEmayiliConnector$new(
    from = "statismike@gmail.com",
    smtp = emayili::gmail(
      username = "statismike@gmail.com",
      password = Sys.getenv("STATISMIKE_GMAIL_PASS")
    ),
    custom_mails = custom_emails
  )
}

recovered_message <- NULL

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
  
})
