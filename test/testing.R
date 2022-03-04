library(shiny.reglog)

googlesheets4::gs4_auth("statismike@gmail.com")

 options("RegLogServer.logs_to_database" = 0)

mail_message <- RegLogConnectorMessage(
  "register_mail",
  username = "Testowy",
  email = "mninten90@gmail.com",
  mail_subject = "testing",
  mail_body = "<p>I am testing this!</p>"
)

ui <- fluidPage(style = "max-width: 600px;",
  tabsetPanel(
    tabPanel("Login",
             RegLog_login_UI()),
    tabPanel("Register",
             RegLog_register_UI()),
    tabPanel("Edit credentials",
             RegLog_credsEdit_UI()),
    tabPanel("Reset password",
             RegLog_resetPass_UI())
  ),
  fluidRow(
   actionButton("logout", "Log out"),
  actionButton("browser", "Browser"),
  verbatimTextOutput("state")))

server <- function(input, output, session) {
  
  dbConnectorMariaDB <- RegLogDBIConnector$new(
    driver = RMariaDB::MariaDB(),
    user = Sys.getenv("MARIADB_LOCAL_USER"),
    password = Sys.getenv("MARIADB_LOCAL_PASS"),
    host = "localhost",
    port = 3306,
    dbname = "reglog_system"
  )
  
  dbConnectorSQLite <- RegLogDBIConnector$new(
    driver = RSQLite::SQLite(),
    dbname = "/home/kosin/Documents/sqlite/users.sqlite"
  )
  
  dbConnectorgsheet <- RegLogGsheetConnector$new(
    gsheet_ss = "1argj0wG_gBAM6VoaRwXOLoDJ6k69LfAZfBgb330vA4I"
  )
  
  mailConnector <- RegLogEmayiliConnector$new(
    from = "statismike@gmail.com",
    smtp = emayili::gmail("statismike@gmail.com", Sys.getenv("STATISMIKE_GMAIL_PASS"))
  )
  
  RegLog <- RegLogServer$new(
    dbConnector = dbConnectorgsheet,
    mailConnector = mailConnector
  )
  
  observeEvent(input$browser, browser())
  
  observeEvent(input$logout, RegLog$logout())
  
  output$state <- renderPrint(RegLog$message())
  
}

shinyApp(ui, server)