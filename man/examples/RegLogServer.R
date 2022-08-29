# Run only in interactive session #

if (interactive()) {
  
  library(shiny.reglog)
  
  # for exemplary setup temporary SQLite database will be created
  library("DBI")
  library("RSQLite")
  temp_sqlite <- tempfile(fileext = ".sqlite")
  conn <- DBI::dbConnect(RSQLite::SQLite(),
                         dbname = temp_sqlite)
  DBI_tables_create(conn)
  DBI::dbDisconnect(conn)
  
  # create minimalistic UI
  ui <- navbarPage(
    title = "RegLog system",
    tabPanel("Register", RegLog_register_UI("custom_id")),
    tabPanel("Login", RegLog_login_UI("custom_id")),
    tabPanel("Credentials edit", RegLog_credsEdit_UI("custom_id")),
    tabPanel("Password reset", RegLog_resetPass_UI("custom_id"))
  )
  
  # create server logic
  server <- function(input, output, session) {
    
    # create dbConnector with connection to the temporary SQLite database
    dbConnector <- RegLogDBIConnector$new(
      driver = RSQLite::SQLite(),
      dbname = temp_sqlite)
    
    # create mockup mailConnector
    mailConnector <- RegLogConnector$new()
    
    # create RegLogServer
    RegLog <- RegLogServer$new(
      dbConnector = dbConnector,
      mailConnector = mailConnector,
      ## all arguments below are optional! ##
      app_name = "RegLog example",
      app_address = "https://reglogexample.com",
      lang = "en",
      # custom texts as a named list with strings
      custom_txts = list(
        user_id = "Name of the user",
        register_success_t= "Congratulations - you have been registered in 
                             successfully with RegLog system!"),
      # use modals as a named list of FALSE to inhibit specific modal
      use_modals = list(
        login_success = FALSE),
      # custom module id - provide the same to the UI elements!
      module_id = "custom_id")
  }
  
  shinyApp(ui, server)
}
