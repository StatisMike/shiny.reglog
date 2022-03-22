# auth
googlesheets4::gs4_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                        path = Sys.getenv("G_SERVICE_ACCOUNT"),
                        cache = F)
googledrive::drive_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                        path = Sys.getenv("G_SERVICE_ACCOUNT"),
                        cache = F)

# create mockup data
user_data <- data.frame(
  username = "RegLogTesting",
  password = "Reg1Log2Test!",
  email = "RegLogTest@example.com"
)

gsheet_ss <- NULL

test_that("created googlesheet tables are correct", {
  
  expect_failure(
    expect_error(
      gsheet_ss <<- gsheet_tables_create(
        user_data = user_data,
        hash_passwords = TRUE,
        use_log = TRUE,
        verbose = FALSE
      )))
  
  expect_failure(
    expect_error(
      account_data <- googlesheets4::read_sheet(
        gsheet_ss,
        sheet = "account")
    )
  )
  
  expect_equal(nrow(account_data), 1)
  expect_equal(names(account_data), 
               c("username", "password", "email", "create_time", "update_time"))
  
  expect_failure(
    expect_error(
      reset_data <- googlesheets4::read_sheet(
        gsheet_ss,
        sheet = "reset_code"
      )
    )
  )
  
  expect_equal(names(reset_data),
               c("user_id", "reset_code", "used", "create_time", "update_time"))
  
  expect_failure(
    expect_error(
      log_data <- googlesheets4::read_sheet(
        gsheet_ss,
        sheet = "logs"
      )
    )
  )
  
  expect_equal(names(log_data),
               c("time", "session", "direction", "type", "note"))
  
})

# create custom handler

get_account_handler <- function(self, private, message) {
  
  table <- googlesheets4::read_sheet(
    private$gsheet_ss,
    sheet = "account")
  
  return(RegLogConnectorMessage(
    type = message$type, table = table,
    logcontent = "Got data from 'account' table"
  ))
}

server <- function(input, output, session) {
  
  dbConnector <- RegLogGsheetConnector$new(
    gsheet_ss = gsheet_ss,
    custom_handlers = list(
      get_account = get_account_handler
    ))
}

recovered_message <- NULL
recovered_logs <- NULL

testServer(server, {
  
  dbConnector$listener(
    RegLogConnectorMessage(
      type = "get_account"
    )
  )
  
  session$elapse(5000)
  
  recovered_message <<- dbConnector$message()
  recovered_logs <<- dbConnector$get_logs()
  
})

test_that("GsheetConnector handles handler functions", {
  
  expect_equal(
    c(user_data$username,
      user_data$email),
    c(recovered_message$data$table$username,
      recovered_message$data$table$email))
  
  expect_true(scrypt::verifyPassword(
    hash = recovered_message$data$table$password,
    passwd = user_data$password
  ))
})

test_that("GsheetConnector get logs correctly", {
  
  expect_equal(nrow(recovered_logs), 2)
  expect_equal(names(recovered_logs),
               c("direction", "time", "session", "type", "note"))
  expect_equal(recovered_logs$direction, c("received", "sent"))
  expect_equal(recovered_logs$type, rep("get_account", times = 2))
  expect_true(recovered_logs$time[1] < recovered_logs$time[2])
  
})

googledrive::drive_trash(gsheet_ss)