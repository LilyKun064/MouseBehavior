#' Check consistency of behaviour summary
#'
#' - Entry1 should not be after the test duration.
#' - If Entry1 is NA, Time and all Min columns should be 0.
#'
#' @param behavior_summary Data.frame of summaries (rows = mice).
#' @param behaviors Character vector of behaviour base names.
#' @param t Test length in minutes.
#'
#' @return Invisibly returns the data.frame; issues warnings on problems.
#' @export
mb_check_behavior_summary <- function(behavior_summary,
                                      behaviors,
                                      t = 6) {
  max_time <- t * 60
  any_warn <- FALSE
  
  for (i in seq_len(nrow(behavior_summary))) {
    mouse_id <- behavior_summary$MouseID[i]
    
    for (b in behaviors) {
      entry_col <- paste0(b, "Entry1")
      time_col  <- paste0(b, "Time")
      
      if (!entry_col %in% names(behavior_summary) ||
          !time_col  %in% names(behavior_summary)) {
        next
      }
      
      entry_val <- behavior_summary[[entry_col]][i]
      time_val  <- behavior_summary[[time_col]][i]
      
      # 1) entry after test duration
      if (!is.na(entry_val) && entry_val > max_time) {
        warning("MouseID ", mouse_id, ": ", entry_col,
                " = ", entry_val, " > ", max_time, " sec.")
        any_warn <- TRUE
      }
      
      # 2) NA entry but non-zero time or minutes
      if (is.na(entry_val)) {
        if (!is.na(time_val) && time_val != 0) {
          warning("MouseID ", mouse_id, ": ", entry_col,
                  " is NA but ", time_col, " = ", time_val, " != 0.")
          any_warn <- TRUE
        }
        
        for (seg in 1:t) {
          min_col <- paste0(b, "Min", seg)
          if (min_col %in% names(behavior_summary)) {
            val <- behavior_summary[[min_col]][i]
            if (!is.na(val) && val != 0) {
              warning("MouseID ", mouse_id, ": ", min_col,
                      " = ", val, " != 0 while ", entry_col, " is NA.")
              any_warn <- TRUE
            }
          }
        }
      }
    }
  }
  
  if (!any_warn) {
    message("No inconsistencies detected in behavior_summary.")
  }
  
  invisible(behavior_summary)
}
