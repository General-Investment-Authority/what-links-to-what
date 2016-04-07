.onLoad <- function(libname, pkgname) {
  #never ever ever ever ever convert strings to factors
  options(stringsAsFactors = FALSE)
  options(java.parameters = "-Xmx4g")
}

