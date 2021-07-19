if(googlesheets4::gs4_has_token()){

gsheet.id <- create_gsheet_db()

database <- gsheet_get_db(gsheet.id)

# you can then pass 'gsheet.id' to you 'login_server' call
#
# login_server(db_method = "gsheet",
#              gsheet_file = gsheet.id,
#              ...)
#

print(database)

googledrive::drive_trash(gsheet.id)

}
