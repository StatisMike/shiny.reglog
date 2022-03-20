# auth
library(shiny.reglog)

googlesheets4::gs4_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                        path = Sys.getenv("G_SERVICE_ACCOUNT"),
                        cache = F)
googledrive::drive_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                        path = Sys.getenv("G_SERVICE_ACCOUNT"),
                        cache = F)
gmailr::gm_auth_configure()
gmailr::gm_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                path = Sys.getenv("G_SERVICE_ACCOUNT"))


uneval_dbConnector <- quote(
  RegLogGsheetConnector$new(
    gsheet_ss = Sys.getenv("REGLOG_SHEET")
  )
)

uneval_mailConnector <- quote(
  RegLogGmailrConnector$new(
    from = Sys.getenv("G_SERVICE_ACCOUNT")))


shiny.reglog:::RegLogTest(
  dbConnector = uneval_dbConnector,
  mailConnector = uneval_mailConnector
)