# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

createDescriptions = FALSE
createConcordances = FALSE
printStatistics = FALSE

# two steps:
# 1) creating descriptions for classifications
if (createDescriptions){
  parse_CN()
  parse_CPA()
  parse_HS()
  parse_ISIC()
  parse_NACE()
  parse_NAICS()
  parse_SITC()
}
# 2) creating links between classifications
if (createConcordances){
  link_CN_to_CPA()
  link_CN_to_SITC()
}

if(printStatistics){
  print_Classification_Statistics()
}
