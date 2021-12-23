1# shiny.reglog 0.2.0.0

* Added a `NEWS.md` file to track changes to the package.
* Added function to create valid databases for usage of shiny.reglog system: `create_sqlite_db` and `create_gsheet_db`

2# shiny.reglog 0.3.0

* Added `credentials` argument to `create_sqlite_db` to create SQLite database containing some data
* Removed `use_language` from exported functions, as its functionality is minimal out of its usage context
* `sqlite_get_db` and `gsheet_get_db` functions are now exported, as their functionality grew with added `credentials` argument
* Fixed `user_id` value returned by `login_server` function for anonymous users. It is now in form of `paste("Anon", Sys.time(), sep = "_")` to force its reads as `character` object. Before it could be read as `datetime` object while reading from 'googlesheets' database and it caused some bugs

3# shiny.reglog 0.4.0

* Added `credentials` argument to `create_gsheet_db`, mirroring the same functionality of `create_sqlite_db`
* Added `logout_button` function, providing the users a way to log out during usage of ShinyApp
* Added description of how to provide credentials to `create_sqlite_db` and `create_gsheet_db` functions 
* Created vignette specifying the authorization process for `gmailr` and `googlesheets4` to use their methods of email sending and database storage
* Removed `dbplyr` dependency

4# shiny.reglog 0.4.2

* Added optional argument to `login_server`: `use_login_modals` enabling developer to silence systemic modals
after any or all login attempts
* Added `last_state_change` to the reactiveValues object, that is returned from `login_server`. It enables to
listen to last state changes of login procedure. Currently it supports only state changes from login procedure, so it can take
this values:
  - "init", if no state change was made
  - "login_UserNotFound", if the user tried to login with non-existing username
  - "login_WrongPass", if the user provided incorrect password
  - "login_Success", if the user has been logged successfully
