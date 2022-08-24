skip("WIP")

test_data <- data.frame(
  username = c("reglog_testing", "reglogger"),
  password = c("IamAtest1", "IamAtest2"),
  email = c("reglog@testing.com", "testing@reglog.com")
)

mongo_default <- list(
  url = "mongodb://localhost",
  db = "reglog"
)

mongo_tables_create(
  mongo_url = mongo_default$url,
  mongo_db = mongo_default$db,
  user_data = test_data,
  hash_passwords = TRUE,
  verbose = F
)

dbConnector <- quote(RegLogMongoConnector$new(
  mongo_url = mongo_default$url,
  mongo_db = mongo_default$db
))

mailConnector <- quote(RegLogConnector$new())

shiny.reglog:::RegLogTest(dbConnector = dbConnector,
                          mailConnector = mailConnector)

account <- mongolite::mongo(db = mongo_default$db, collection = "account")
account$drop()
account$disconnect()
resetCode <- mongolite::mongo(db = mongo_default$db, collection = "reset_code")
resetCode$drop()
resetCode$disconnect()

# server <- function(input, output, session) {
#   
#   dbConnector <- RegLogMongoConnector$new(
#     mongo_url = mongo_default$url,
#     mongo_db = mongo_default$db
#   )
#   
# }
# 
# message_to_test <- NULL
# 
# testServer(server, {
#   
#   dbConnector$listener(RegLogConnectorMessage(
#     "login",
#     username = test_data$username[1],
#     password = test_data$password[1]
#   ))
#   
#   observe({
#     req(dbConnector$message()$type == "login")
#     message_to_test <<- dbConnector$message()
#     })
#   
# })
