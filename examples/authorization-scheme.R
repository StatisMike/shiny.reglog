# Code for gargle authorization processess

# these needed for both gmailr and gsheet methods
your_gmail_address = "my.mail@gmail.com"
path_to_your_secrets = "my/secrets/path"

# these needed only for gmailr
GoogleCloudConsole_ClientID = "My ClientID"
GoogleCloudConsole_ClientSecret = "My Secret"

## optional
# app <- httr::oauth_app(appname = "My New App", 
#                        key = GoogleCloudConsole_ClientID, 
#                        secret = GoogleCloudConsole_ClientSecret)
# googlesheets4::gs4_auth_configure(app = app)


# this needed for gsheet method
googlesheets4::gs4_auth(email = your_gmail_address,
                        cache = path_to_your_secrets)

## this needed for gmailr method
gmailr::gm_auth_configure(key = GoogleCloudConsole_ClientID, 
                          secret = GoogleCloudConsole_ClientSecret)

gmailr::gm_auth(
  email = your_gmail_address,
  cache = path_to_your_secrets,
  scopes = "send")