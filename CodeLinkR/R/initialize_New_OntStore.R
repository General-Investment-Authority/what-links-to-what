initialize_New_OntStore <- function(){
  ontStore = new.rdf()
  add.prefix(ontStore, "skos", "http://www.w3.org/2004/02/skos/core#")
  add.prefix(ontStore, "rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
  return(ontStore)
}
