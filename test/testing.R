library(shiny.reglog)

mail_message <- RegLogConnectorMessage(
  "register_mail",
  username = "Testowy",
  email = "mninten90@gmail.com",
  mail_subject = "testing",
  mail_body = "<p>I am testing this!</p>"
)

ui <- fluidPage(
  fluidRow(
    column(4,
           RegLog_login_UI(),
           actionButton("logout",
                        "Log out")),
    column(4,
           RegLog_register_UI()),
    column(4, 
           RegLog_edit_UI())
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
  
  mailConnector <- RegLogEmayiliConnector$new(
    from = "statismike@gmail.com",
    smtp = emayili::gmail("statismike@gmail.com", Sys.getenv("STATISMIKE_GMAIL_PASS"))
  )
  
  RegLog <- RegLogServer$new(
    dbConnector = dbConnector,
    mailConnector = mailConnector
  )
  
  observeEvent(input$browser, browser())
  
  observeEvent(input$logout, RegLog$logout())
  
  output$state <- renderPrint(RegLog$message())
  
}

shinyApp(ui, server)