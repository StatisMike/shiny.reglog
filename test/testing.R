library(shiny.reglog)

ui <- fluidPage(
  RegLog_login_UI(),
  actionButton("browser",
               "Browser"),
  actionButton("logout",
               "Log out")
)

server <- function(input, output, session) {
  
  dbConnector <- RegLogDBIConnector$new(
    driver = RMySQL::MySQL(),
    user = Sys.getenv("REGLOG_MYSQL_USER"),
    password = Sys.getenv("REGLOG_MYSQL_PASS"),
    host = "localhost",
    port = 3306,
    dbname = "reglog_test"
  )
  
  mockConnector <- RegLogConnector$new()
  
  RegLog <- RegLogServer$new(
    dbConnector = dbConnector,
    mailConnector = mockConnector
  )
  
  observeEvent(input$browser, browser())
  
  observeEvent(input$logout, RegLog$logout())
  
}

shinyApp(ui, server)