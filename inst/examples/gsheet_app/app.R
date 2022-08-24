library(shiny.reglog)

googlesheets4::gs4_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                        path = Sys.getenv("G_SERVICE_ACCOUNT"),
                        cache = F)
googledrive::drive_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                        path = Sys.getenv("G_SERVICE_ACCOUNT"),
                        cache = F)

tryCatch(
  googlesheets4::sheet_delete(id, c("account", "reset_code")), 
  error = function(e) { })

gsheet_tables_create(gsheet_ss = Sys.getenv("REGLOG_SHEET"))

shiny.reglog:::RegLogTest(
  dbConnector = RegLogGsheetConnector$new(
    gsheet_ss = Sys.getenv("REGLOG_SHEET")
  ),
  mailConnector = RegLogConnector$new(),
  use_modals = F,
  onStart = {
    options("RegLogServer.logs_to_database" = 0)
    options("RegLogServer.logs" = 1)
  }
)
