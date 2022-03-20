# create mockup data
user_data <- data.frame(
  username = "RegLogTesting",
  password = "Reg1Log2Test!",
  email = "RegLogTest@example.com"
)

# create SQLite database
tempsqlite <- tempfile(fileext = ".sqlite")

conn <- DBI::dbConnect(
  RSQLite::SQLite(),
  dbname = tempsqlite
)

test_that("created DBI tables are correct", {
  
  expect_failure(
    expect_error(
      DBI_tables_create(
        conn = conn,
        user_data = user_data,
        hash_passwords = TRUE,
        use_log = TRUE,
        verbose = FALSE
      )))
  
  expect_failure(
    expect_error(
      account_data <- DBI::dbReadTable(
        conn = conn,
        name = "account"
      )
    )
  )
  
  expect_equal(nrow(account_data), 1)
  expect_equal(names(account_data), 
               c("id", "username", "password", "email", "create_time", "update_time"))
  
  expect_failure(
    expect_error(
      reset_data <- DBI::dbReadTable(
        conn = conn,
        name = "reset_code"
      )
    )
  )
  
  expect_equal(names(reset_data),
               c("id", "user_id", "reset_code", "used", "create_time", "update_time"))
  
  expect_failure(
    expect_error(
      log_data <- DBI::dbReadTable(
        conn = conn,
        name = "logs"
      )
    )
  )
  
  expect_equal(names(log_data),
               c("id", "time", "session", "direction", "type", "note"))
  
})

DBI::dbDisconnect(conn)

# create custom handler

get_account_handler <- function(self, private, message) {
  
  private$db_check_n_refresh()
  on.exit(private$db_disconnect())
  
  table <- DBI::dbReadTable(private$db_conn,
                            name = "account")
  
  return(RegLogConnectorMessage(
    type = message$type, table = table,
    logcontent = "Got data from 'account' table"
  ))
}

server <- function(input, output, session) {
  
  dbConnector <- RegLogDBIConnector$new(
    driver = RSQLite::SQLite(),
    dbname = tempsqlite,
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
  
  session$elapse(300)
  
  recovered_message <<- dbConnector$message()
  recovered_logs <<- dbConnector$get_logs()
  
})

test_that("DBIConnector handles handler functions", {
  
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

test_that("DBIConnector get logs correctly", {
  
  expect_equal(nrow(recovered_logs), 2)
  expect_equal(names(recovered_logs),
               c("direction", "time", "session", "type", "note"))
  expect_equal(recovered_logs$direction, c("received", "sent"))
  expect_equal(recovered_logs$type, rep("get_account", times = 2))
  expect_true(recovered_logs$time[1] < recovered_logs$time[2])
  
})
