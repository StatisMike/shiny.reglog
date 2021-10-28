## ----setup, include = FALSE--------------------------------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- eval = F---------------------------------------------------------------------------------------------
#      # Setting up OAuth app isn't mandatory, though it is recommended
#      # more details about this in next session
#  
#      # app <- httr::oauth_app(
#      #   appname = "your app name", # only shows during asking for permission in browser
#      #   key = "Your Client ID",
#      #   secret = "Your Client Secret")
#  
#      googlesheets4::gs4_auth(
#        email = "gmail used to access the spreadsheets",
#        # it is recommended to cache the secret in place where it is easy
#        # to find initially. You will need to copy the file to the Shiny Server.
#        # After copying it is preferable to hide it for the security
#        cache = "path/to/secrets"
#        )

## ---- eval = F---------------------------------------------------------------------------------------------
#      gmailr::gm_auth_configure(
#         key = "Your Client ID",
#         secret = "Your Client Secret"
#      )
#  
#      gmailr::gm_auth(
#        email = "gmail which will be used to send e-mails",
#        # it is recommended to cache the secret in place where it is easy
#        # to find initially. You will need to copy the file to the Shiny Server.
#        # After copying it is preferable to hide it for the security
#        cache = "path/to/secrets",
#        scopes = "send"
#        )

