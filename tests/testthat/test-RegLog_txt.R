custom_txts <- list(
  user_id = "User identificator",
  login_success_b = "You have been logged nicely!"
)

test_that("RegLog_txt returns every language correctly", {
  
  languages <- shiny.reglog:::RegLog_txts$.languages_registered
  
  dicts <- lapply(
    languages,
    \(lang) RegLog_txt(lang = lang)
  )
  
  for (i_lang in 2:length(languages)) {
    
    expect_equal(names(dicts[[1]]), 
                 names(dicts[[i_lang]]))
    
  }
  
})

test_that("RegLog_txt returns custom txts in whole lang", {
  
  dict <- RegLog_txt("en",
                     custom_txts = custom_txts)
  
  for (nm in names(custom_txts))
    expect_equal(custom_txts[[nm]],
                 dict[[nm]])
  
})

test_that("RegLog_txt returns custom txts with specific field", {
  
  for (field in names(shiny.reglog:::RegLog_txts$en)[1:5]) {
    
    expect_equal(
      RegLog_txt("en",
                 x = field,
                 custom_txts = custom_txts),
      if (field %in% names(custom_txts)) custom_txts[[field]]
      else shiny.reglog:::RegLog_txts$en[[field]]
    )
  }
})
