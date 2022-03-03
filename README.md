
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shiny.reglog

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN
status](https://www.r-pkg.org/badges/version/shiny.reglog)](https://CRAN.R-project.org/package=shiny.reglog)
[![CRAN
checks](https://cranchecks.info/badges/worst/shiny.reglog)](https://cranchecks.info/pkgs/shiny.reglog)
[![](http://cranlogs.r-pkg.org/badges/last-month/shiny.reglog?color=green)](https://cran.r-project.org/package=shiny.reglog)
[![](http://cranlogs.r-pkg.org/badges/grand-total/shiny.reglog?color=blue)](https://cran.r-project.org/package=shiny.reglog)

<!-- badges: end -->

## 1. Introduction

The user authentication in Shiny applications can be very useful.
Mainly, user can login to read and write some results of their session
into relational database.

On the other hand, it may be handy for your App to allow access of
unregistered users. If you need to secure your ShinyApp, there are
better alternatives
(<a href="https://github.com/datastorm-open/shinymanager" target="_blank">shinymanager</a>
or
<a href="https://github.com/PaulC91/shinyauthr" target="_blank">shinyauthr</a>)

This package contains modules to use in your Shiny application allowing
you to automatically insert boxes for login, register, credentials edit
and password reset and procedures.

*shiny.reglog* supports as database containers either databases accessed
with `RSQLite`, `RMariaDB`, `RMySQL` and `RPostgreSQL` drivers or
googlesheets-based database (accessed by `googlesheets4` package).

It is highly recommended to use one of the `DBI`-supported databases,
though. It is much more optimized and secure, as the whole database is
never loaded as a whole into the memory, but queried as needed.
*googlesheets* database is much easier to set-up, but it shouldn’t be
used when you are expecting big userbase.

Registration, credentials edit and password reset procedures
programmatically send email to the user of your ShinyApp - to welcome
them, inform about change of their user ID and/or email and to give them
a reset code to reset their password. *shiny.reglog* supports two
methods of email sending: via `emayili` or `gmailr` packages. Both of
them have their pros and cons, depending on your accesses: `emayili`
allows for usage of many SMTP servers, while `gmailr` allowing using
*gmail* messaging via Google REST API.

For some informations about getting basic Google REST API authorization
you can read vignette:
<a href="https://cran.r-project.org/web/packages/shiny.reglog/vignettes/auth.html" target="_blank">shiny.reglog: How to get Google API authorization</a>

Currently the package is after major change in its code - basically full
rewrite to allow more security, usage of more databases and more
customization allowed for the end-user. Past functions are still
available in current version, but will generate deprecation warnings.

All new functions are prefixed with `RegLog`, so try to make the switch
to them.

## 2. Basic structure

## 2. Installation

You can install this version of shiny.reglog from GitHub with:

``` r
# install version 0.4.0.1 from CRAN 
install.packages("shiny.reglog")

# or install latest version from GitHub
# install.packages("devtools")
# devtools::install_github("StatisMike/shiny.reglog")
```

## 3. Setup

To use the contents of this package, can use helper functions included
in the package.

### 3.1 Googlesheet database method

1.  Create googlesheet file on your googledrive to support database. It
    creates empty spreadsheet.

``` r
# create googlesheet and gather its id for later usage
# you can also specify optional 'name' argument for custom gsheet name

gsheet_id <- create_gsheet_db()

# save you gsheet_id - you need to provide it later to login_server()
```

If you wish to import some credentials, you can do it by giving the
`data.frame` object to the `credentials` argument:

``` r
# get some credentials
credentials <- data.frame(
  timestamp = Sys.time(),
  user_id = "ShinyReglogTest",
  user_mail = "shinyreglog@test",
  user_pass = "VeryHardPassword"
  )

# create gsheet database with some credentials
gsheet_id <- create_gsheet_db(
  credentials = credentials,
  # when giving some credentials, you need to specify if the passwords were hashed by 'scrypt` package
  credentials_pass_hashed = F)
```

2.  Configure googlesheets4 package to use out-of-band (non-interactive)
    auth. For more information about it visit [googlesheets4
    documentation](https://googlesheets4.tidyverse.org/) or vignette
    provided with `shiny.reglog`

### 3.2 SQLite database method

Create an SQLite database that your Shiny App will have access to. It
creates empty database.

``` r
# create SQLite database and gather its filepath for later usage

create_sqlite_db("path/to/db.sqlite")

# you need to provide 'path/to/db.sqlite' later to login_server()
```

If you wish to import some credentials, you can do it by giving the
`data.frame` object to the `credentials` argument:

``` r
# get some credentials
credentials <- data.frame(
  timestamp = Sys.time(),
  user_id = "ShinyReglogTest",
  user_mail = "shinyreglog@test",
  user_pass = "VeryHardPassword"
  )

# create SQLite database with some credentials
create_sqlite_db(
  "path/to/db.sqlite",
  credentials = credentials,
  # when giving some credentials, you need to specify if the passwords were hashed by 'scrypt` package
  credentials_pass_hashed = F)
```

## 4. Information about functions

All functions generates text (input labels, descriptions, authomatic
e-mail). You can control the language of displayed text with `lang`
argument. Currently it supports English (the default) and Polish
(`lang = "pl"`). If you want to use non-default language, you need to
set the ‘lang’ argument consistently between all functions of the
package.

### 4.1. UI functions

All UI functions creates a `div` element which can be input into UI of
your application, inside a `fluidRow`, complete `fluidPage`, `tabItem`
of dashboard or any other container of your choosing.

#### 4.1.1. register_UI

The register box contains inputs for user ID (which can be used to link
the user with other elements in external databases), e-mail address
(which will be used to send confirmation e-mail and reset codes for your
password) and for password and password repetition. It tests validity of
all inputs and tries to register new account after pushing the
“Register” button.

It produces modal dialog detailing the result. Additionally, if
registered successfully it sends user a confirmation e-mail.

Currently the functions accept user ID and password consisting of 8\~25
alphanumeric characters. It is planned to change in future iterations to
widen the requirements - especially for passwords.

Provided password is saved in hashed form - using the
`scrypt::hashPassword` function.

[![Register UI - click for
gif!](https://statismike.github.io/gallery/shiny.reglog/1_register.png)](https://statismike.github.io/gallery/shiny.reglog/1_register.gif)

#### 4.1.2. login_UI

The login box contains inputs for user ID and password. After pushing
the “Login” button, it check validity of inputs and logins user.
Produces modal dialog detailing results.

<a href="https://statismike.github.io/gallery/shiny.reglog/2_login.gif" target="_blank"><img src="https://statismike.github.io/gallery/shiny.reglog/2_login.png" alt="Login UI - click for gif!" /></a>

#### 4.1.3. password_reset_UI

The box for password reset consists of two UI elements: the
password_reset_UI `div` element and modal dialog it produces after
confirming validity of inputted confirmation code.

The main `div` contains input for User ID. After user inputs their ID,
they should push “Send code” button, which generates their 24h-valid
resetcode mails it to their e-mail and stores in hashed form in the
database.

After they receive reset code, they need to input it in the next
inputbox below and push next button. The validity of inputted code in
relation to user ID is then checked. If correct, the new modal dialog
opens to input the new password.

<a href="https://statismike.github.io/gallery/shiny.reglog/3_reset1.gif" target="_blank"><img src="https://statismike.github.io/gallery/shiny.reglog/3_reset1.png" alt="Reset UI - click for gif!" /></a>

The user need to provide new password and repeat it to check for any
typos. After pushing the “Confirm new password” button, below input
boxes a message is rendered to give feedback to the user - if the
password was changed successfully. After that, the user can close modal
dialog with “OK” button.

<a href="https://statismike.github.io/gallery/shiny.reglog/4_reset2.gif" target="_blank"><img src="https://statismike.github.io/gallery/shiny.reglog/4_reset2.png" alt="Reset modal dialog - click for gif!" /></a>

#### 4.1.4. logout_button

Simple `actionButton` for your users to log out during ShinyApp session.
Clicking it brings on `modalDialog` asking if they are sure that they
want to logout.

### 4.2. Server function

Currently there is only one server function: login_server()

``` r
login_server(
  id = "login_system", 
  db_method = c("gsheet", "sqlite"), 
  mail_method = c("emayili", "gmailr"),
  appname,
  appaddress,
  lang = "en",
  gsheet_file,
  sqlite_db,
  gmailr_user,
  emayili_user,
  emayili_password,
  emayili_host,
  emayili_port
  )
```

#### 4.2.1. Arguments

`login_server` arguments can be divided into three main groups:

##### 4.2.1.1 General arguments: always mandatory

These arguments are always mandatory while using `login_server`

-   *id* argument defaults to “login_system”. You can use different
    name - but remember to keep it consistent for all functions
-   *db_method* specify which database method you want to use. At this
    moment there are two methods for databases: `gsheet` and `sqlite`
-   *mail_method* specify which e-mailing method you want to use. At
    this moment there are two methods fo e-mailing: `gmailr` and
    `emayili`
-   *appname* is the character string with title of your application
-   *appaddress* is the character string with URL address of your
    application for your users to navigate from their confirmation mail
-   *lang* argument defaults to “en”. It changes the language of your
    modules. Currently only one other option is available: “pl” for
    Polish

##### 4.2.1.2 Arguments specific to database methods

-   *gsheet_file* is the character string containing your googlesheets
    ID. Argument is mandatory when using `gsheet` database method
-   *sqlite_db* is the character string specifying path to your sqlite
    database path. Argument is mandatory when using `sqlite`

##### 4.2.1.3 Arguments specific to e-mail methods

-   *gmailr_user* is the character string of your gmail address that you
    wish the application to use for automatic e-mails. Used in `gmailr`
    mailing method

-   *emayili_user* is the character string of your email address, that
    is also used to log into your mailbox. Used in `emayili` mailing
    method, as the ones below.

-   *emayili_password* is the character string of password that you use
    to log into your mailbox

-   *emayili_host* is the character string specifying the sending host
    of your mailbox (fe. `smtp.gmail.com` for gmail mailbox)

-   *emayili_port* is the character string containing the sending port
    of your mailbox (fe. `465` for gmail mailbox)

#### 4.2.2. Values

`login_server` function creates `reactiveValues` object containing three
elements, describing the status of current sessions’ active user.

-   *is_logged* returns a boolean indicating, if the user is anonymous
    (`FALSE`) or logged in (`TRUE`)
-   *user_id* returns a character string containing the ID specyfied
    during registration and used to log-in. When `is_logged = F` it
    countains the timestamp of time when the anonymous user began his
    session. It can be used to link specific activities and outputs
    generated by the same person.
-   *user_mail* returns a character string containing the email address
    provided during registration. It can be used for automatic sending
    the user some kind of e-mails (fe. containing the results of some
    analysis after using your ShinyApp). When `is_logged = F` it
    contains the empty string value (`""`)

Additionally, it stores the tibbles of `user_db` and `reset_db` content
under `session$userData` inside `reactive_db` object of `reactiveValues`
class.

``` r
# save the output in the server function of you application

auth <- login_server(...)

# you can check if currently the user is logged

isTRUE(auth$is_logged)

# moreover, you can check what is the ID and mail of currently logged user

user_data <- list(
  ID = auth$user_id,
  mail = auth$user_mail
)
```

## 5. Examples

Examples of `shiny.reglog` implementation with varying methods for
database and e-mail implementation both in base `shiny` and
`shinydashboard` are contained within `examples` folder.

## 6. User feedback

As it is package in very early development, please give any feedback
after using it. Open new *Issues* or mail any suggestions to [my
e-mail](mailto:statismike@gmail.com?subject=shiny.reglog)
