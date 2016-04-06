print_Classification_Statistics <- function(){
  ontStore = initialize_New_OntStore()
  files = list.files(path="./data/Turtle", pattern=".turtle", full.names=TRUE)
  for (file in files){
    load.rdf(file, "TURTLE", ontStore)
  }

  print(paste("Total number of concepts:", get_Concept_Count(ontStore)))
  print("Available Classifications:")
  print(get_Schemes(ontStore))
}
