get_classification_versions <- function(name){
  classificationMetaData = yaml.load_file("./inst/classifications.yaml")
  versions = c()
  for (classification in classificationMetaData$classifications){
    if (classification$name == name){
      versions = classification$versions
    }
  }
  return(versions)
}

get_concordance_versions <- function(name){
  concordanceMetaData = yaml.load_file("./inst/concordances.yaml")
  versions = c()
  for (concordances in concordanceMetaData$concordances){
    if (concordances$name == name){
      versions = concordances$versions
    }
  }
  return(versions)
}

