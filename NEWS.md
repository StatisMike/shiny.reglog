# shiny.reglog 0.5.0

With the release of v0.5.0 there are a lot of changes in the current implementation
of the RegLog system. Most of the changes were implemented to provide more
customization options in implementing `shiny.reglog` in your ShinyApp and to
widen its possibilities. At the same time I've strived to make the historical
features still accessible, so it shouldn't be harder to use for novice 
Shiny developers.

Instead of using single function to run all logic for RegLog system (as was the
case in deprecated `login_server`) it introduces three main components:
*RegLogServer*, two *dbConnectors* and two *mailConnectors*. Below are listed
the main changes and improvements over previous release. For more details
you can read two detailed vignettes: *RegLogServer object: fields and methods*
and *Creating custom RegLogConnector handlers*.

- main logic is now encapsulated in `RegLogServer` R6 class. Arguments provided during
initialization of object provide options for customization, and more importantly
objects of classes providing connection to the database (`RegLogDBIConnector` or
`RegLogGsheetConnector) and to your e-mail provider (`RegLogEmayiliConnector`
or `RegLogGmailrConnector`). 
  - application can now observe for all state changes made during the lifespan
  of the application accessing the `RegLogServer$message()` reactiveVal.
  - default *modalDialogs* can now be inhibited - either all together (`use_modals = F`)
  or specifically (providing named list of `FALSE` bool values to `use_modals` argument)
- the improved presentation of password reset procedure don't make it necessary
for invoking `modalDialog`. It makes the UI more flexible for this process more
flexible.
- there is also added logic for credentials change procedure: it is now possible
to change password, user ID and user e-mail after registration.
- class `RegLogGsheetConnector` provides support for storing the userbase inside
googlesheet. It contains the past functionality of `db_method = 'gsheet'` in
`login_server`.
  - there have been made some additional improvements: now it mirrors the behaviour
  of SQL databases: password changes don't append new rows to the googlesheet,
  but changes the whole row accordingly, which makes menaging the database
  much simpler.
- class `RegLogDBIConnector` provides support for storing the userbase inside
`DBI` handled database. It improves on original support for SQLite database, 
providing also out-of-box support for multiple MySQL, MariaDB and PostgreSQL
databases.
- both *mailConnectors* improves on the functionality of emailing methods
of now deprecated `login_server`.
  - they allow explicitly modifying all send e-mails to the users.
  - they send e-mails after register, reset password and credentials change
  procedure (user ID and/or e-mail).
  - they also support sending custom e-mails after custom events.
- both *dbConnectors* and *mailConnectors* allow appending custom *handler functions*,
either to modify the default ones or providing completely new functionalities.

To sum up, newly introduced functions/classes and their deprecated ancestors:

- `RegLogServer` class replaces `login_server`
- `RegLog_login_UI` function replaces `login_UI`
- `RegLog_register_UI` function replaces `register_UI`
- `RegLog_resetPass_UI` function replaces `password_reset_UI`
- `RegLog_credsEdit_UI` function introduces credential edit UI functionality.
- `RegLogDBIConnector` class replaces `login_server(db_method = "sqlite")` and 
widen the usability
- `RegLogGsheetConnector` class replaces `login_server(db_method = "gsheet")`
- `RegLogEmayiliConnector` class replaces `login_server(email_method = "emayili")`
- `RegLogGmailrConnector` class replaces `login_server(email_method = "gmailr")`
- `RegLog_txt` function replaces `reglog_txt`
- `DBI_tables_create` function replaces `create_sqlite_db` with added functionality
- `gsheet_tables_create` replaces `create_gsheet_db`
- `RegLogConnectorMessage` function to parse your own messages to *connectors*
- `RegLogConnector` class to create your own *connectors*

Deprecated without direct replacement:

- `logout_button`: using `RegLogServer$logout()` method creating own logout
logic is straightforward.
- `sqlite_get_db` and `gsheet_get_db`: getting tables and sheets is straightforward
using functions from `DBI` or `googlesheets4` packages

# shiny.reglog 0.4.2

* Added optional argument to `login_server`: `use_login_modals` enabling developer to silence systemic modals
after any or all login attempts
* Added `last_state_change` to the reactiveValues object, that is returned from `login_server`. It enables to
listen to last state changes of login procedure. Currently it supports only state changes from login procedure, so it can take
this values:
  - "init", if no state change was made
  - "login_UserNotFound", if the user tried to login with non-existing username
  - "login_WrongPass", if the user provided incorrect password
  - "login_Success", if the user has been logged successfully

# shiny.reglog 0.4.0

* Added `credentials` argument to `create_gsheet_db`, mirroring the same functionality of `create_sqlite_db`
* Added `logout_button` function, providing the users a way to log out during usage of ShinyApp
* Added description of how to provide credentials to `create_sqlite_db` and `create_gsheet_db` functions 
* Created vignette specifying the authorization process for `gmailr` and `googlesheets4` to use their methods of email sending and database storage
* Removed `dbplyr` dependency

# shiny.reglog 0.3.0

* Added `credentials` argument to `create_sqlite_db` to create SQLite database containing some data
* Removed `use_language` from exported functions, as its functionality is minimal out of its usage context
* `sqlite_get_db` and `gsheet_get_db` functions are now exported, as their functionality grew with added `credentials` argument
* Fixed `user_id` value returned by `login_server` function for anonymous users. It is now in form of `paste("Anon", Sys.time(), sep = "_")` to force its reads as `character` object. Before it could be read as `datetime` object while reading from 'googlesheets' database and it caused some bugs


# shiny.reglog 0.2.0.0

* Added a `NEWS.md` file to track changes to the package.
* Added function to create valid databases for usage of shiny.reglog system: `create_sqlite_db` and `create_gsheet_db`
