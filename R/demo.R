#' @title Demonstration ShinyApp with basic RegLog system
#' 
#' @description 
#' You can play a little with RegLogSever functionalities launching this ShinyApp.
#' This demo needs also an installation of 'RSQLite' package to create and
#' menage a temporary database.
#' 
#' @param emayili_smtp defined emayili smtp server for you e-mail provider. 
#' If kept as default NULL, the e-mail sending functionality won't
#' be used. If provided, it will require an installation of 'emayili' package.
#' @param emayili_from String containing e-mail from which thesending will take place.
#' Used only with 'emayili_smtp' defined.
#' 
#' @export
#' 

RegLogDemo <- function(emayili_smtp = NULL,
                       emayili_from = NULL) {
  
  check_namespace("RSQLite")
  check_namespace("DT")
  
  # create a temporary database
  sqlite_db <- tempfile(fileext = ".sqlite")
  conn <- DBI::dbConnect(
    RSQLite::SQLite(),
    dbname = sqlite_db
  )
  DBI_tables_create(conn = conn, verbose = F)
  DBI::dbDisconnect(conn)
  
  # define custom handler function to read all data from the tables
  
  get_table_handler <- function(self, private, message) {
    
    private$db_check_n_refresh()
    on.exit(private$db_disconnect())
    
    table <- DBI::dbReadTable(private$db_conn,
                              message$data$table_name)
    
    return(RegLogConnectorMessage(
      type = message$type, table = table,
      logcontent = paste("Got data from", message$data$table_name)
    ))
  }
  
  # create an UI
  
  ui <- fluidPage(
    column(width = 6,
           tabsetPanel(
             type = "pills",
             header = tags$p(
               "Change the tabs to access different elements of the RegLog UI.
             You can register a new account in the temporary database (it will
             be cleared after exiting the session) to test the functionalities).",
               if (is.null(emayili_smtp)) 
                 tags$p("No e-mail messages will be send in this demo") else ""),
             tabPanel("Register", RegLog_register_UI()),
             tabPanel("Login", RegLog_login_UI()),
             tabPanel("Credentials edit", RegLog_credsEdit_UI()),
             tabPanel("Password reset", RegLog_resetPass_UI()))),
    column(width = 6,
           tabsetPanel(
             type = "pills",
             header = tags$p(
               "Change the tabs to see the current state of the RegLogServer
               or preview the contents of the database."),
             tabPanel("RegLogServer state",
                      tags$h2("Current user data"),
                      verbatimTextOutput("user_data"),
                      tags$h2("Current 'RegLogServer$message()' contents"),
                      verbatimTextOutput("reglog_message")),
             tabPanel("Gathered logs",
                      tags$h2("Check the currently gathered logs"),
                      tags$p("RegLogServer by default saves all sent and received
                             messages into its 'log' field. By clicking the button
                             below you will trigger use of 'get_logs()' method
                             to gather them all into data.frame."),
                      actionButton("logs", "Get all logs"),
                      DT::DTOutput("gotten_logs")),
             tabPanel("Database lookup",
                      tags$h2("Read the current state of the database tables."),
                      tags$p("You can select one of two tables created by default
                             in the database. After clicking the button contents
                             of this table will be shown below."),
                      tags$p("This functionality uses", tags$i("custom handler function"),
                             "actually - so it will change the contents of the",
                             tags$i("message"), "field and it will be saved into",
                             tags$i("logs.")),
                      selectInput("select_table", "Select table",
                                  c("account", "reset_code")),
                      actionButton("get_table", "Send the message"),
                      DT::DTOutput("db_lookup"))
           )))
  
  server <- function(input, output, server) {
    
    # initialize the dbConnect
    dbConnector <- RegLogDBIConnector$new(
      driver = RSQLite::SQLite(),
      dbname = sqlite_db,
      custom_handlers = list(get_table = get_table_handler)
    )
    
    # initialize the mailConnector - use mock connector if no emayili smtp is
    # provided
    if (is.null(emayili_smtp)) {
      mailConnector <- RegLogConnector$new()
    } else {
      # requireNamespace("emayili")
      mailConnector <- RegLogEmayiliConnector$new(
        from = emayili_from,
        smtp = emayili_smtp
      )
    }
    
    # initialize main module
    RegLog <- RegLogServer$new(
      dbConnector = dbConnector,
      mailConnector = mailConnector
    )
    
    output$user_data <- renderPrint(
      list("is_logged" = RegLog$is_logged(),
           "user_id" = RegLog$user_id(),
           "user_mail" = RegLog$user_mail(),
           "account_id" = RegLog$account_id())
    )
    
    output$reglog_message <- renderPrint(
      RegLog$message()
    )
    
    observeEvent(input$logs, {
      output$gotten_logs <- DT::renderDT(
        RegLog$get_logs()
      )
    })
    
    # send the message
    observeEvent(input$get_table, {
      dbConnector$listener(
        RegLogConnectorMessage(
          "get_table",
          table_name = input$select_table)
      )
    })
    
    # render the table contents
    output$db_lookup <- DT::renderDT({
      req(RegLog$message()$type == "get_table")
      RegLog$message()$data$table},
      options = list(scrollX = TRUE))
  }
  
  shinyApp(ui = ui,
           server = server)
  
}

#' Bare RegLog ShinyApp to use for testing purposes
#' 
#' @param dbConnector unevaluated dbConnector
#' @param mailConnector unevaluated mailConnector
#' @param onStart unevaluated expression to run before initializing session
#' @noRd

RegLogTest <- function(dbConnector,
                       mailConnector,
                       onStart = NULL) {
  
  # create an UI
  
  ui <- fluidPage(
    shinyjs::useShinyjs(),
    column(width = 6,
           tabsetPanel(id = "reglogtabset",
             tabPanel("Register", RegLog_register_UI()),
             tabPanel("Login", RegLog_login_UI()),
             tabPanel("Credentials edit", RegLog_credsEdit_UI()),
             tabPanel("Password reset", RegLog_resetPass_UI()))),
    column(width = 6,
           h2("RegLogServer state"),
           tags$h2("Current user data"),
           verbatimTextOutput("user_data"),
           tags$h2("Current 'RegLogServer$message()' contents"),
           verbatimTextOutput("reglog_message"),
           actionButton("logout", "Log-out"),
           actionButton("logs", "Get logs"),
           actionButton("browser", "Debug")))
  
  server <- function(input, output, server) {
    
    eval(onStart)
    
    dbConnector <- eval(dbConnector)
    mailConnector <- eval(mailConnector)
    
    # initialize main module
    RegLog <- RegLogServer$new(
      dbConnector = dbConnector,
      mailConnector = mailConnector,
      use_modals = F
    )
    
    output$user_data <- renderPrint(
      list("is_logged" = RegLog$is_logged(),
           "user_id" = if (isTRUE(RegLog$is_logged())) RegLog$user_id() else "not_logged",
           "user_mail" = RegLog$user_mail(),
           "account_id" = RegLog$account_id())
    )
    
    output$reglog_message <- renderPrint({
      req(RegLog$message()$type != "ping")
      RegLog$message()[-1] 
    })
    
    observeEvent(input$logs, RegLog$get_logs())
    
    observeEvent(input$logout, RegLog$logout())
    
    observeEvent(input$browser, browser())
  }
  
  shinyApp(ui = ui,
           server = server)
  
}
