# auth
library(shiny.reglog)

uneval_dbConnector <- quote(RegLogMongoConnector$new(
  mongo_url = "mongodb://localhost",
  mongo_db = "reglog"
))

uneval_mailConnector <- quote(RegLogConnector$new())

shiny.reglog:::RegLogTest(
  dbConnector = uneval_dbConnector,
  mailConnector = uneval_mailConnector,
  hide_account_id = T
)
