#' Check that a CowLog file has required columns
#'
#' @param file A data.frame.
#' @param filename Optional filename for messages.
#'
#' @return The same data.frame (invisibly), or an error if columns are missing.
#' @export
mb_check_columns <- function(file, filename = NA_character_) {
  required <- c("time", "code", "class")
  missing  <- setdiff(required, names(file))
  
  if (length(missing) > 0L) {
    stop(
      "File ",
      ifelse(is.na(filename), "", paste0(filename, " ")),
      "is missing required columns: ",
      paste(missing, collapse = ", ")
    )
  }
  
  invisible(file)
}
