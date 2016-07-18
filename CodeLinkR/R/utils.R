trim <- function(text){
  text = gsub("[ |\n]*$", "", text)
  return(text)
}
