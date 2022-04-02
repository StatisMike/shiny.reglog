# setup database

skip("WIP")
requireNamespace("DBI")
requireNamespace("RSQLite")

temp_db <- tempfile(fileext = ".sqlite")
  
conn <- DBI::dbConnect(RSQLite::SQLite(),
                       dbname = temp_db)

DBI_tables_create(conn)

DBI::dbDisconnect(conn)

# setup server

server <- function(input, output, session) {
  
  dbConnector <- RegLogDBIConnector$new(
    driver = RSQLite::SQLite(),
    dbname = temp_db
  )
  
  RegLog <- RegLogServer$new(
    dbConnector = dbConnector,
    mailConnector = RegLogConnector$new(),
    use_modals = F
  )
  
}

# tests with testServer

testServer(server, {
  
  test_that("User is succesfully registered", {
    
    session$setInputs("login_system-register_user_ID" = "NewUserTest",
                      "login_system-register_email" = "NewUser@test.com",
                      "login_system-register_pass1" = "InAGaddaDaVida1",
                      "login_system-register_pass2" = "InAGaddaDaVida1")
    
    session$setInputs("login_system-register_bttn" = NULL)
    session$setInputs("login_system-register_bttn" = 0)
    
    observe({
      RegLog$message()
      
      req(session$input[["login_system-register_bttn"]])
      
      switch(as.character(session$input[["login_system-register_bttn"]]),
             
             "0" = {
               expect_equal(RegLog$message()$type, "register")
               expect_true(RegLog$message()$success)
             }
             
             )
    })
    
    
    
  })
  
})