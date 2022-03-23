# long-running test - skip on CRAN

skip_on_cran()

# create SQLite database
temp_db <- tempfile(fileext = ".sqlite")

Sys.setenv(REGLOG_TEMP_SQLITE = temp_db)

conn <- DBI::dbConnect(
  RSQLite::SQLite(),
  dbname = temp_db
)

DBI_tables_create(conn = conn)

DBI::dbDisconnect(conn)

test_that("User register works correctly.", {
  
  tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)
  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_DBI_emayili"), 
                       compareImages = FALSE,
                       testnames = "register")
  }, action = "prefix")
  shinytest::expect_pass(results)
  
})

test_that("User login works correctly.", {
  
  tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)
  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_DBI_emayili"), 
                       compareImages = FALSE,
                       testnames = "login")
  }, action = "prefix")
  shinytest::expect_pass(results)
  
})

test_that("User credsEdit works correctly.", {
  
  tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)
  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_DBI_emayili"), 
                       compareImages = FALSE,
                       testnames = "credsEdit")
  }, action = "prefix")
  shinytest::expect_pass(results)
  
})

test_that("User resetPass works correctly.", {
  
  tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)
  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_DBI_emayili"), 
                       compareImages = FALSE,
                       testnames = "resetPass")
  }, action = "prefix")
  shinytest::expect_pass(results)
  
})
