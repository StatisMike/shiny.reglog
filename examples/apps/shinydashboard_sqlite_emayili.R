# NOT RUN {
## Only run this example in interactive R sessions

if(interactive()){
  
  source("../authorization-scheme.R")
  
  library(shiny)
  library(shinydashboard)
  library(shiny.reglog)
  
  # initializing sqlite
  
  sqlite.path <- tempfile(fileext = "sqlite")
  create_sqlite_db(sqlite.path)
  database <- sqlite_get_db(sqlite.path)
  
  # Define UI containing shiny.reglog modules
  ui <- dashboardPage(
    dashboardHeader(title = "shiny.reglog example"),
    dashboardSidebar(
      uiOutput("sidePanel"),
      sidebarMenu(
        menuItem("Login", tabName = "login"),
        menuItem("Register", tabName = "register"),
        menuItem("Reset Password", tabName = "resetpass"),
        menuItem("Values", tabName = "values")
      )
    ),
    
    dashboardBody(
      tabItems(
        tabItem("login",
                fluidPage(
                  login_UI()
                )),
        tabItem("register",
                fluidPage(
                  register_UI()
                )),
        tabItem("resetpass",
                fluidPage(
                  password_reset_UI()
                )),
        tabItem("values",
                fluidPage(
                  dataTableOutput("active_user_values"),
                  dataTableOutput("user_db"),
                  dataTableOutput("reset_db")
                ))
      )
    )
  )
  
  # Define server logic required to draw a histogram
  server <- function(input, output, session) {
    
    # login server with specified methods for database and mailing
    # to run it you need to replace placeholders with your details and 
    # cofigure it for your needs
    
    auth <- login_server(
      db_method = "sqlite",
      mail_method = "emayili",
      appname = "shiny.reglog example",
      appaddress = "not-on-net.com",
      sqlite_db = sqlite.path,
      # arguments below need configuration for your mailing account
      emayili_user = "your_email_address",
      emayili_password = "your_email_password",
      emayili_port = "your_email_box_port",
      emayili_host = "your_email_box_host"
    )
    
    #table of values returned by login_server
    
    output$active_user_values <- renderDataTable({
      data.frame(is_logged = auth$is_logged,
                 user_id = auth$user_id,
                 user_mail = auth$user_mail
      )
    })
    
    # tibbles contained within session$userData$reactive_db
    
    output$user_db <- renderDataTable(
      session$userData$reactive_db$user_db
    )
    
    output$reset_db <- renderDataTable(
      session$userData$reactive_db$reset_db
    )
    
    # you can use the values from login_server in your app!
    
    output$sidePanel <- renderUI({
      
      req(as.logical(auth$is_logged))  # rendering only if user is logged
      
      list(
        sidebarUserPanel(                # userPanel containing active user's ID and mail
          name = auth$user_id,
          subtitle = auth$user_mail
        ),
        logout_button()
        )
    })
  }
  
  # Run the application 
  shinyApp(ui = ui, server = server)
  
}

# }
