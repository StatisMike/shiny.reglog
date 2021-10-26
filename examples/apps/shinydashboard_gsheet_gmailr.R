# NOT RUN {
## Only run this example in interactive R sessions

if(interactive()){
  
  source("../authorization-scheme.R")
  
  library(shiny)
  library(shinydashboard)
  library(shiny.reglog)
  
  ## initialize gsheet database
  gsheet_id <- create_gsheet_db()
  
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
      db_method = "gsheet",
      mail_method = "gmailr",
      appname = "shiny.reglog example",
      appaddress = "not-on-net.com",
      gsheet_file = gsheet_id,
      gmailr_user = your_gmail_address
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
