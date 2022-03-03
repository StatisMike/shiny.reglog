library(shiny.reglog)

# mockup user data
user_data <- 
  data.frame(username = c("Whatever", "Hanuka", "Helsinki", "How_come"), 
             password = c("&f5*MSYj^niDt=V'3.[dyEX.C/", "%}&B[fs\\}5PKE@,*+V\\tx9\"at]", 
                          "35z*ofW\\'G_8,@vCC`]~?e$Jm%", "s:;r_eLn?-D6;oA-=\"^R(-Ew<x"), 
             email = c("what@mil.com", "hehe@soso.so", "nider@what.no", "crazzz@simpsy.com"))

# create the tables and input the data (hashing the passwords in the process)
id <- gsheet_tables_create(user_data = user_data,
                           hash_passwords = TRUE)

# check generated googlesheet
googlesheets4::gs4_get(id)

# check the "user" sheet for user data
googlesheets4::read_sheet(id, "user")

# disconnect
googledrive::drive_trash(id)
