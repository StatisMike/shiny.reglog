# proven authorization for gmailr and googlesheets4. May be redundant, but is stable
# at the time of publication for non-interactive authorization. 
#
# If you are more knowledgable of gargle-driven packages
# you are welcome to create minimal working setup

app <- httr::oauth_app(appname = "name of your app", 
                       key = "your Oauth2 client ID", 
                       secret = "your Oauth2 secret")

googledrive::drive_auth_configure(app = app)

googledrive::drive_auth(email = "your_google_email",
                        cache = ".secrets",
                        scopes = c("https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/gmail.send"))
googlesheets4::gs4_auth(
  email = "your_google_email",
  token = googledrive::drive_token())

gmailr::gm_auth_configure(path = "path_to_your_json_Oauth_app.json")
gmailr::gm_auth(
  email = "your_google_email",
  token = googledrive::drive_token())