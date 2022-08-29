library(testthat)
library(shinytest2)
library(shiny.reglog)

app_wait <- function(app,
                     time = 1000) {
  
  app$.__enclos_env__$private$shiny_process$interrupt()
  app$.__enclos_env__$private$shiny_process$wait(timeout = time)
}

test_check("shiny.reglog")
