#' Summarise all behaviours for a single file
#'
#' @param file Cleaned CowLog data.frame for one mouse.
#' @param behaviors Character vector of behaviour base names.
#' @param t Test length in minutes.
#' @param mouse_id Optional MouseID; if NULL, you can set it later.
#'
#' @return One-row data.frame with columns:
#'   MouseID, <b>Time, <b>Entry1, <b>Bouts, <b>Min1..MinT.
#' @export
mb_summarise_file <- function(file,
                              behaviors,
                              t = 6,
                              mouse_id = NULL) {
  
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required. Please install it.")
  }
  
  mb_check_columns(file)
  
  if (is.null(mouse_id)) {
    mouse_id <- "Unknown"
  }
  
  result <- data.frame(MouseID = mouse_id, stringsAsFactors = FALSE)
  
  for (b in behaviors) {
    s <- mb_summarise_behavior(file, behavior = b, t = t)
    
    time_col   <- paste0(b, "Time")
    entry_col  <- paste0(b, "Entry1")
    bouts_col  <- paste0(b, "Bouts")
    min_cols   <- paste0(b, "Min", 1:t)
    
    result[[time_col]]  <- s$time
    result[[entry_col]] <- s$entry1
    result[[bouts_col]] <- s$bouts
    
    for (seg in 1:t) {
      result[[min_cols[seg]]] <- s$min[seg]
    }
  }
  
  result
}
