test_that("Deprecated login_server works", {
  
  tmp_lib <- ensurePackagePresent(pkgName = "shiny.reglog", quiet = F)
  results <- withr::with_libpaths(tmp_lib, {
    shinytest::testApp(appDir = testthat::test_path("../shinyTest_login_server"), 
                       compareImages = FALSE)
  }, action = "prefix")
  shinytest::expect_pass(results)
  
})