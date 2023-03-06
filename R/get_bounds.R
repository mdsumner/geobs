#' Get geoboundaries in a dataframe from zipped geoboundaries with a code and level.
#'
#' Currently hardcoded to gbOpen, see https://github.com/wmgeolab/geoBoundaries/tree/main/releaseData/gbOpen
#'
#' There's no caching done, but the function get_bounds is memoized.
#' See examples for available codes.
#'
#' @param code 3-letter code
#' @param level administrative level (of detail, e.g. "ADM1")
#' @param simplified return the simplified layer for the level, `FALSE` is default
#' @param srctype 'shp' by default, but on advisement (use 'geojson' or 'topojson' for alternative)
#' @param quiet simple debug messages are printed if this is `TRUE`
#' @param data return the data, or just the source and layer name, default is `TRUE`
#' @param what read "fields" or "geometry" or "" (both)
#'
#' @return data frame with fields and geometry (see [wk::wkb])
#' @export
#' @importFrom tibble as_tibble
#' @importFrom vapour vapour_read_fields vapour_read_geometry
#' @importFrom wk wkb
#' @importFrom memoise memoize
#' @examples
#' get_bounds("EGY", simplified = TRUE)
#'
#' ## get a table of codes and levels
#' b <- "https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData"
#' codes <- readr::read_csv(file.path(b, "geoBoundariesOpen-meta.csv"))
#' subset(codes, boundaryISO == "SWE", select = c("boundaryISO", "boundaryName", "boundaryType"))
get_bounds <- function(code = "AUS", level = "ADM0", simplified = TRUE, srctype = "shp",  quiet = TRUE, data = TRUE, what = "") {
  simplif <- ""
  if (simplified) {
    simplif <- "_simplified"
  }
  ## layers are
  #geoBoundaries-SWE-ADM1 (Polygon)
  #geoBoundaries-SWE-ADM1_simplified
  # SWEADM1gbOpen
  layer <- sprintf("geoBoundaries-%s-%s%s", code, level, simplif)

  srcbase <- sprintf("/vsizip//vsicurl/https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData/gbOpen/%s/%s/geoBoundaries-%s-%s-all.zip", code, level, code, level)
  if (srctype == "geojson") {
   #srcbase<- sprintf("/vsicurl/https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData/gbOpen/%s/%s/geoBoundaries-%s-%s%s.geojson", code, level, code, level, simplif)
   srcbase<- file.path(srcbase, sprintf("%s.geojson", layer))
  }

  if (srctype == "topojson") {
   srcbase <- sprintf("/vsicurl/https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData/gbOpen/%s/%s/geoBoundaries-%s-%s%s.topojson", code, level, code, level, simplif)
    layer <- sprintf("%s%sgbOpen", code, level)
  }
  if (!quiet) print(str(vapour::vapour_layer_info(srcbase, layer)))
  if (!data) {
    return(tibble::tibble(dsn = srcbase,
             layer = layer))
  }
  if (what == "") {
    d <- tibble::as_tibble(vapour_read_fields(srcbase, layer))
    d$geometry <- wk::wkb(vapour_read_geometry(srcbase, layer))
  }
  if (what == "geometry") {
    d <- tibble(geometry = wk::wkb(vapour_read_geometry(srcbase, layer)))
  }
  if (what == "fields") {
    d <- tibble::as_tibble(vapour_read_fields(srcbase, layer))
  }
  d
}
