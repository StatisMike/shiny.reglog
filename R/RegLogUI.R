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

RegLog_credsEdit_UI <- function(module_id = "login_system") {
  
  ns <- NS(module_id)
  
  uiOutput(ns("creds_edit_ui"))
  
}

#' Generate ResetPass code UI for RegLog system
#'  
#' @param module_id Character declaring the id of the module. Defaults to 'login_system'.
#' Recommended to keep it that way, unless it would cause any namespace issues.
#'
#'
#' @family RegLog UI
#' @import shiny
#' @export

RegLog_resetPass_UI <- function(module_id = "login_system") {
  
  ns <- NS(module_id)
  
  uiOutput(ns("reset_pass_ui"))
  
}