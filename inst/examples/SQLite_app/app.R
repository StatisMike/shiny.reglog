library(shiny.reglog)

SQLite_db <- tempfile(fileext = ".sqlite")

conn <- DBI::dbConnect(
  RSQLite::SQLite(),
  dbname = SQLite_db
)

DBI_tables_create(
  conn = conn,
  use_log = T
)

DBI::dbDisconnect(conn)

shiny.reglog:::RegLogTest(
  dbConnector = RegLogDBIConnector$new(
    RSQLite::SQLite(),
    dbname = SQLite_db
  ),
  mailConnector = RegLogConnector$new(),
  use_modals = F,
  onStart = {
    options("RegLogServer.logs_to_database" = 1)
    options("RegLogServer.logs" = 1)
  }
)