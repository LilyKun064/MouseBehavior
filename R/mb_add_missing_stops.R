#' Insert missing Stop rows after Start events
#'
#' For any row whose code ends with "Start", if the next row is not a matching
#' "Stop" (and not END), a Stop row is inserted at the time of the next row.
#' Also adds a Stop if the next row is END.
#'
#' @param file A data.frame with columns time, code, class.
#'
#' @return A data.frame with additional Stop rows inserted and sorted by time.
#' @export
mb_add_missing_stops <- function(file) {
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("Package 'stringr' is required. Please install it.")
  }
  
  mb_check_columns(file)
  
  file$time <- as.numeric(file$time)
  
  new_rows <- data.frame(
    time  = numeric(),
    code  = character(),
    class = numeric(),
    stringsAsFactors = FALSE
  )
  
  n <- nrow(file)
  if (n > 1L) {
    for (i in 1:(n - 1L)) {
      this_code <- file$code[i]
      next_code <- file$code[i + 1L]
      
      if (stringr::str_detect(this_code, "Start$")) {
        if (identical(next_code, "END") ||
            !stringr::str_detect(next_code, "Stop$")) {
          new_rows <- rbind(
            new_rows,
            data.frame(
              time  = file$time[i + 1L],
              code  = sub("Start$", "Stop", this_code),
              class = file$class[i],
              stringsAsFactors = FALSE
            )
          )
        }
      }
    }
  }
  
  if (nrow(new_rows) > 0L) {
    file <- rbind(file, new_rows)
    file <- file[order(file$time), , drop = FALSE]
  }
  
  file
}
