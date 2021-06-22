#### example of db_method = "sqlite" and mail_method = "emayili"

# gmailR and googlesheets configuration should be contained in external .R file, restricted to shiny user

library(shiny)
library(shiny.reglog)

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
        tabPanel("Reset Password", password_reset_UI())
    )
)

server <- function(input, output, session) {
    
    # login server with specified methods for database and mailing
    # to run it you need to replace placeholders with your details and 
    # cofigure it for your needs
    
    auth <- login_server(
        db_method = "sqlite",
        mail_method = "emayili",
        appname = "shiny.reglog test",
        appaddress = "not-on-net.com",
        sqlite_db = "test.sqlite",
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
