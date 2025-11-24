#' Fill NA values in summary according to forced swim rules
#'
#' - all *Min columns: NA -> 0
#' - all *Time columns: NA -> 0
#' - all *Entry1 columns: NA -> -9
#'
#' @param behavior_summary Data.frame of behaviour summaries.
#'
#' @return Data.frame with NA values replaced.
#' @export
mb_fill_na_summary <- function(behavior_summary) {
  if (!requireNamespace("dplyr", quietly = TRUE) ||
      !requireNamespace("tidyr", quietly = TRUE)) {
    stop("Packages 'dplyr' and 'tidyr' are required. Please install them.")
  }
  
  dplyr::mutate(
    behavior_summary,
    dplyr::across(dplyr::ends_with("Min"),
                  ~ tidyr::replace_na(., 0)),
    dplyr::across(dplyr::ends_with("Time"),
                  ~ tidyr::replace_na(., 0)),
    dplyr::across(dplyr::ends_with("Entry1"),
                  ~ tidyr::replace_na(., -9))
  )
}
