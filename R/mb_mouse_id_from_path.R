#' Derive MouseID from file path
#'
#' Example: "Mouse1_ForcedSwim.csv" -> "Mouse1"
#'
#' @param path File path.
#'
#' @return Character MouseID.
#' @export
mb_mouse_id_from_path <- function(path) {
  base <- sub("\\..*$", "", basename(path))
  strsplit(base, "_")[[1]][1]
}
