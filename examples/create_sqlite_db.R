sqlite.path <- tempfile(fileext = "sqlite")

create_sqlite_db(sqlite.path)

shiny.reglog:::.sqlite_get_db(sqlite.path)

# you can then pass 'sqlite.path' to you 'login_server' call
#
# login_server(db_method = "sqlite",
#              sqlite_db = sqlite.path,
#              ...)
#