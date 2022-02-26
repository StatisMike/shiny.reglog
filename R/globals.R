# to remove "no visible binding for global variable" with dplyr functions

utils::globalVariables(c("timestamp", "user_id", "user_mail"))

# deprecate messages

R6switch_deprecate_mssg <- "Starting from `shiny.reglog` v0.5.0 the login and registration logic is completely reworked. It is advised to move to the new functions, which allows for much more freedom. For instructions on setting up new logic see vignette 'Setup `shiny.reglog` system'"

# supported connections

supported_db_connections <- c("SQLiteConnection", "MySQLConnection")