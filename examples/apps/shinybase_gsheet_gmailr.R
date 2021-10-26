# NOT RUN {
## Only run this example in interactive R sessions

if(interactive()){

#### example of db_method = "gsheets" and mail_method = "gmailr"

# gmailR and googlesheets configuration should be contained in external .R file, restricted to shiny user
# before running this example check the file and add correct information
# for more details see the vignette in this package
  
source("../authorization-scheme.R")

library(shiny)
library(shiny.reglog)
  
gsheet_id <- create_gsheet_db()

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

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    # login server with specified methods for database and mailing
    # to run it you need to replace placeholders with your details and 
    # cofigure it for your needs
    
    auth <- login_server(
        db_method = "gsheet",
        mail_method = "gmailr",
        appname = "shiny.reglog test",
        appaddress = "not-on-net.com",
        gsheet_file = gsheet_id,
        gmailr_user = your_gmail_address
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

googledrive::drive_trash(gsheet_id)

}
# }