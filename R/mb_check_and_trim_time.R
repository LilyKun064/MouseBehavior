#' Check duration, trim to test window, and enforce END row
#'
#' - Checks whether recording duration roughly matches expected test length.
#' - Trims any rows after test end.
#' - Ensures there is an END row at the final time.
#'
#' @param file A data.frame with columns time, code, class.
#' @param filename Optional filename for messages.
#' @param t Test length in minutes (default 6).
#'
#' @return A data.frame trimmed to the test window with final END row.
#' @export
mb_check_and_trim_time <- function(file,
                                   filename = NA_character_,
                                   t = 6) {
  
  mb_check_columns(file, filename)
  
  if (nrow(file) == 0L) {
    warning("File ", filename, " has 0 rows.")
    return(file)
  }
  
  file$time <- as.numeric(file$time)
  
  total_time <- suppressWarnings(
    file$time[nrow(file)] - file$time[1]
  )
  
  if (!is.na(total_time)) {
    expected <- t * 60
    if (total_time > expected) {
      warning("File ", filename, ": total_time = ", total_time,
              " > expected ", expected, " sec.")
    } else if (total_time < expected) {
      warning("File ", filename, ": total_time = ", total_time,
              " < expected ", expected, " sec.")
    }
  }
  
  # limit time
  limit_time <- file$time[1] + t * 60
  
  # trim
  file <- file[file$time <= limit_time, , drop = FALSE]
  
  # ensure END row at limit_time
  last_code <- if (nrow(file) > 0L) file$code[nrow(file)] else NA_character_
  if (!identical(last_code, "END")) {
    new_row <- data.frame(
      time  = limit_time,
      code  = "END",
      class = 0,
      stringsAsFactors = FALSE
    )
    file <- rbind(file, new_row)
  }
  
  file
}
