# auth
library(shiny.reglog)

uneval_dbConnector <- bquote(
  RegLogDBIConnector$new(
    driver = RSQLite::SQLite(),
    dbname = .(Sys.getenv("REGLOG_TEMP_SQLITE"))
  )
)

uneval_mailConnector <- quote(
  RegLogEmayiliConnector$new(
    from = "reglog@testing.com",
    smtp = emayili::smtpbucket()))

shiny.reglog:::RegLogTest(
  dbConnector = uneval_dbConnector,
  mailConnector = uneval_mailConnector
)
