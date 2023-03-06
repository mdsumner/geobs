#' Get geoboundaries in a dataframe from zipped geoboundaries with a code and level.
#'
#' Currently hardcoded to gbOpen, see https://github.com/wmgeolab/geoBoundaries/tree/main/releaseData/gbOpen
#'
#' There's no caching done, but the function get_bounds is memoized.
#' See examples for available codes.
#'
#' @param code 3-letter code
#'
#' @return data frame with fields and geometry (see [wk::wkb])
#' @export
#' @importFrom tibble as_tibble
#' @importFrom vapour vapour_read_fields vapour_read_geometry
#' @importFrom wk wkb
#' @importFrom memoise memoize
#' @examples
#' get_bounds("EGY")
#'
#' ## get a table of codes and levels
#' codes <- readr::read_csv("https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData/geoBoundariesOpen-meta.csv")
#' subset(codes, boundaryISO == "SWE", select = c("boundaryISO", "boundaryName", "boundaryType"))
get_bounds <- function(code = "AUS", level = "ADM1", simplified = FALSE) {
  f <- sprintf("/vsizip//vsicurl/https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData/gbOpen/%s/%s/geoBoundaries-%s-%s-all.zip", code, level, code, level)
  ## layers are
  #geoBoundaries-SWE-ADM1 (Polygon)
  #geoBoundaries-SWE-ADM1_simplified
  simplif <- ""
  if (simplified) {
    simplif <- "_simplified"
  }
  layer <- sprintf("geoBoundaries-%s-%s%s", code, level, simplif)
  d <- tibble::as_tibble(vapour_read_fields(f, layer))
  d$geometry <- wk::wkb(vapour_read_geometry(f, layer))
  d
}
