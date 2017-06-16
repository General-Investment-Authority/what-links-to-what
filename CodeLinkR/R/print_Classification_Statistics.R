print_Classification_Statistics <- function(){
  ontStore = initialize_New_OntStore()
  files = list.files(path="./data/Turtle", pattern=".turtle", full.names=TRUE)
  for (file in files){
    load.rdf(file, "TURTLE", ontStore)
  }

  print(paste("Total number of concepts:", get_Concept_Count(ontStore)))
  print("Available Classifications:")
  print(get_Schemes(ontStore))

  endpoint = "http://localhost:9999/blazegraph/sparql"
  schemes = get_Schemes(endpoint)

  stats = get_Number_of_Links_Between_Schemes(endpoint)

  # need to write output like:
  #digraph G {
  #rankdir=LR
  #"CN/2016" -> "CPA/2008" [label= "skos:narrowMatch" penwidth= 3.9251573272 ]
  #}


}
