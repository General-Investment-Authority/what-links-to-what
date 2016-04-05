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

