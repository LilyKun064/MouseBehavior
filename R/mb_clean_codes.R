#' Clean and standardize CowLog codes
#'
#' - Removes spaces within codes ("ActiveSwim Start" -> "ActiveSwimStart").
#' - Normalizes "End" suffixes to "Stop" ("ActiveSwimEnd" -> "ActiveSwimStop").
#'
#' @param file A data.frame with a `code` column.
#'
#' @return A data.frame with standardized code values.
#' @export
mb_clean_codes <- function(file) {
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("Package 'stringr' is required. Please install it.")
  }
  
  if (!"code" %in% names(file)) {
    stop("Input must contain a 'code' column.")
  }
  
  # remove spaces
  file$code <- stringr::str_replace_all(file$code, " ", "")
  
  # normalize End -> Stop
  file$code <- stringr::str_replace(file$code, "End$", "Stop")
  
  file
}
