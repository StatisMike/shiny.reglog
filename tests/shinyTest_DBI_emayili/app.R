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
    from = "statismike@gmail.com",
    smtp = emayili::gmail(username = "statismike@gmail.com",
                          password = Sys.getenv("STATISMIKE_GMAIL_PASS"))))


shiny.reglog:::RegLogTest(
  dbConnector = uneval_dbConnector,
  mailConnector = uneval_mailConnector
)
