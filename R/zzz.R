.onLoad <- function(libname, pkgname) {
  get_bounds <<- memoise::memoize(get_bounds)
}
