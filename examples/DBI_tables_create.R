library(shiny.reglog)

# create a tenporary SQLite database
conn <- DBI::dbConnect(
  RSQLite::SQLite(),
  dbname = ":memory:"
)

# mockup user data
user_data <- 
  data.frame(username = c("Whatever", "Hanuka", "Helsinki", "How_come"), 
             password = c("&f5*MSYj^niDt=V'3.[dyEX.C/", "%}&B[fs\\}5PKE@,*+V\\tx9\"at]", 
                    "35z*ofW\\'G_8,@vCC`]~?e$Jm%", "s:;r_eLn?-D6;oA-=\"^R(-Ew<x"), 
             email = c("what@mil.com", "hehe@soso.so", "nider@what.no", "crazzz@simpsy.com"))

# create the tables and input the data (hashing the passwords in the process)
DBI_tables_create(conn = conn,
                  user_data = user_data,
                  hash_passwords = TRUE)

# check generater tables
DBI::dbListTables(conn = conn)

# check the "user" table for user data
DBI::dbReadTable(conn = conn,
                 "account")

# disconnect
DBI::dbDisconnect(conn = conn)
