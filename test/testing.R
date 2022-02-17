library(shiny.reglog)

ui <- fluidPage(
  fluidRow(
    column(4,
           RegLog_login_UI(),
           actionButton("logout",
                        "Log out")),
    column(4,
           RegLog_register_UI()),
    column(4, 
           RegLog_resetPass_send_code_UI(),
           RegLog_resetPass_confirm_code_UI())
  ),
  fluidRow(
    tags$h1("Debug"),
    actionButton("browser",
                 "Browser"),
    actionButton("logout",
                 "Log out"),
    verbatimTextOutput("state") 
  )
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
  
  output$state <- renderPrint(RegLog$message())
  
}

shinyApp(ui, server)