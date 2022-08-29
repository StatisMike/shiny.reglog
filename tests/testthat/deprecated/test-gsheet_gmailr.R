# long-running test - skip on CRAN

skip("wip")

# auth #

googlesheets4::gs4_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                        path = Sys.getenv("G_SERVICE_ACCOUNT"),
                        cache = F)
googledrive::drive_auth(email = Sys.getenv("G_SERVICE_MAIL"),
                        path = Sys.getenv("G_SERVICE_ACCOUNT"),
                        cache = F)

# prepare gsheet
tryCatch(
    googlesheets4::sheet_delete(id, c("account", "reset_code")), 
    error = function(e) { })

gsheet_tables_create(gsheet_ss = Sys.getenv("REGLOG_SHEET"))

tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)

test_that("User register works correctly.", {

  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_gsheet_gmailr"), 
                       compareImages = FALSE,
                       testnames = "register")
  }, action = "prefix")
  shinytest::expect_pass(results)

})

test_that("User login works correctly.", {
  
  # tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)
  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_gsheet_gmailr"), 
                       compareImages = FALSE,
                       testnames = "login")
  }, action = "prefix")
  shinytest::expect_pass(results)
  
})

test_that("User credsEdit works correctly.", {
  
  # tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)
  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_gsheet_gmailr"), 
                       compareImages = FALSE,
                       testnames = "credsEdit")
  }, action = "prefix")
  shinytest::expect_pass(results)
  
})

test_that("User resetPass works correctly.", {
  
  # tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)
  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_gsheet_gmailr"), 
                       compareImages = FALSE,
                       testnames = "resetPass")
  }, action = "prefix")
  shinytest::expect_pass(results)
  
})
