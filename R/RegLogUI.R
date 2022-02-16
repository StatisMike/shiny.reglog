#'  Generate Login UI for RegLog system
#'  
#' @param module_id Character declaring the id of the module. Defaults to 'login_system'.
#' Recommended to keep it that way, unless it would cause any namespace issues.
#' 
#' @family RegLog UI
#' @import shiny
#' @export

RegLog_login_UI <- function(module_id = "login_system") {
  
  ns <- NS(module_id)
  
  uiOutput(ns("login_ui"))
  
}

#'  Generate Register UI for RegLog system
#'  
#' @param module_id Character declaring the id of the module. Defaults to 'login_system'.
#' Recommended to keep it that way, unless it would cause any namespace issues.
#'
#' @family RegLog UI
#' @import shiny
#' @export

RegLog_register_UI <- function(module_id = "login_system") {
  
  ns <- NS(module_id)
  
  uiOutput(ns("register_ui"))
  
}

#' Generate Edit User Data UI for RegLog system
#'  
#' @param module_id Character declaring the id of the module. Defaults to 'login_system'.
#' Recommended to keep it that way, unless it would cause any namespace issues.
#'
#' @family RegLog UI
#' @import shiny
#' @export

RegLog_edit_UI <- function(module_id = "login_system") {
  
  ns <- NS(module_id)
  
  uiOutput(ns("edit_ui"))
  
}

#' Generate ResetPass code send UI for RegLog system
#'  
#' @param module_id Character declaring the id of the module. Defaults to 'login_system'.
#' Recommended to keep it that way, unless it would cause any namespace issues.
#'
#' @details Password reset procedure needs two-step UI: firstly, provide username
#' and email provided during registration. Secondly, provide reset code send via 
#' email and new password. This function binds the UI for the first step.
#'
#' @family RegLog UI
#' @import shiny
#' @export

RegLog_resetPass_send_code_UI <- function(module_id = "login_system") {
  
  ns <- NS(module_id)
  
  uiOutput(ns("reset_send_ui"))
  
}

#' Generate ResetPass code confirm UI for RegLog system
#'  
#' @param module_id Character declaring the id of the module. Defaults to 'login_system'.
#' Recommended to keep it that way, unless it would cause any namespace issues.
#' 
#' @details Password reset procedure needs two-step UI: firstly, provide username
#' and email provided during registration. Secondly, provide reset code send via 
#' email and new password. This function binds the UI for the second step.
#'
#' @family RegLog UI
#' @import shiny
#' @export

RegLog_resetPass_confirm_code_UI <- function(module_id = "login_system") {
  
  ns <- NS(module_id)
  
  uiOutput(ns("reset_confirm_ui"))
  
}