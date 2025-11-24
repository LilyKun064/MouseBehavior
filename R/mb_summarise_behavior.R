#' Summarise a single behaviour within a file
#'
#' Computes total time, first entry, bouts, and per-minute time for one behaviour.
#'
#' @param file Cleaned CowLog data.frame (after time check + code cleaning).
#' @param behavior Base behaviour name, e.g. "ActiveSwim".
#' @param t Test length in minutes (default 6).
#'
#' @return A list with elements:
#'   time, entry1, bouts, min (numeric vector length t).
#' @export
mb_summarise_behavior <- function(file,
                                  behavior,
                                  t = 6) {
  
  mb_check_columns(file)
  
  file$time <- as.numeric(file$time)
  
  start_code <- paste0(behavior, "Start")
  stop_code  <- paste0(behavior, "Stop")
  
  start_times <- file$time[file$code == start_code]
  stop_times  <- file$time[file$code == stop_code]
  
  start_times <- as.numeric(start_times)
  stop_times  <- as.numeric(stop_times)
  
  # pad stops if fewer than starts
  if (length(stop_times) < length(start_times) && nrow(file) > 0L) {
    stop_times <- c(stop_times, file$time[nrow(file)])
  }
  
  # ensure equal length
  if (length(stop_times) > length(start_times)) {
    stop_times <- stop_times[seq_along(start_times)]
  }
  
  t_sec <- t * 60
  overall_start_time <- file$time[1]
  max_time           <- overall_start_time + t_sec
  
  if (length(start_times) == 0L) {
    total_time <- 0
    entry1     <- NA_real_
    bouts      <- 0L
  } else {
    durations <- stop_times - start_times
    durations <- durations[durations > 0]
    total_time <- sum(durations, na.rm = TRUE)
    entry1     <- start_times[1]
    bouts      <- length(start_times)
  }
  
  # per-minute time
  seg_values <- numeric(t)
  if (length(start_times) > 0L) {
    for (seg in 1:t) {
      seg_start <- overall_start_time + (seg - 1) * 60
      seg_end   <- seg_start + 60
      
      start_overlap <- pmax(seg_start, start_times)
      end_overlap   <- pmin(seg_end,   stop_times)
      seg_durations <- pmax(end_overlap - start_overlap, 0)
      seg_values[seg] <- sum(seg_durations, na.rm = TRUE)
    }
  }
  
  list(
    time   = total_time,
    entry1 = entry1,
    bouts  = bouts,
    min    = seg_values
  )
}
