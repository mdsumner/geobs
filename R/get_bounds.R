#' Get geoboundaries in a dataframe from GeoJSON with a code
#'
#' Currently hardcoded to ADM1, see https://www.geoboundaries.org/api.html
#'
#' @param code 3-letter code
#'
#' @return data frame with fields and geometry (see [wk::wkb])
#' @export
#' @importFrom tibble as_tibble
#' @importFrom vapour vapour_read_fields vapour_read_geometry
#' @importFrom wk wkb
#' @importFrom
#' @examples
#' get_bounds("EGY")
get_bounds <- function(code = "AUS") {
  f <- sprintf("/vsizip//vsicurl/https://geoboundaries.org/data/geoBoundaries-3_0_0/%s/ADM1/geoBoundaries-3_0_0-%s-ADM1-all.zip/geoBoundaries-3_0_0-%s-ADM1.geojson", code, code, code)
  d <- tibble::as_tibble(vapour_read_fields(f))
  d$geometry <- wk::wkb(vapour_read_geometry(f))
  d
}
