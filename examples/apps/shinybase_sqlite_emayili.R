# NOT RUN {
## Only run this example in interactive R sessions

if(interactive()){

#### example of db_method = "sqlite" and mail_method = "emayili"

library(shiny)
library(shiny.reglog)
  
# initializing sqlite

sqlite.path <- tempfile(fileext = "sqlite")
create_sqlite_db(sqlite.path)
database <- sqlite_get_db(sqlite.path)

# Define UI containing shiny.reglog modules
ui <- fluidPage(

    headerPanel(title = "shiny.reglog test"),

    tabsetPanel(
        tabPanel("Values", 
                 # table of returned data for active user
                 dataTableOutput("active_user_values"),
                 # table of session$userData$reactive_db$user_db loaded at the start of session
                 dataTableOutput("user_db"),
                 # table of session$userData$reactive_db$reset_db loaded at the start of session
                 dataTableOutput("reset_db")
        ),
        tabPanel("Login", login_UI()),
        tabPanel("Register", register_UI()),
        tabPanel("Reset Password", password_reset_UI()),
        tabPanel("Logout", logout_button())
        
    )
)

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
    
    # table of values returned by login_server
    
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
}

# Run the application 
shinyApp(ui = ui, server = server)

}

# }
