write_NAICS_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  # add rdf:type skos:ConceptScheme
  add_skos_concept_scheme(ontStore, substring(baseURL, 1, nchar(baseURL)-1))

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Code[i])

    higherCodeURL = ""
    loc = which(ws$Code == substr(ws$Code[i], 1, nchar(ws$Code[i])-1))
    if (any(loc)){
      higherCodeURL = paste0(baseURL, ws$Code[loc])
    }

    if (higherCodeURL != ""){
      add_skos_narrower(ontStore, higherCodeURL, subjectURL)
      add_skos_broader(ontStore, subjectURL, higherCodeURL)
    }

    add_skos_inScheme(ontStore, subjectURL, substring(baseURL, 1, nchar(baseURL)-1))

    add_skos_concept_node(ontStore,
                          conceptId = subjectURL,
                          notation = ws$Code[i],
                          description = ws$Title[i],
                          prefLabel = ws$Code[i])
  }
  save.rdf(ontStore, paste0(turtlePath, "/", codeAbbrev, version, ".turtle"), format="TURTLE")
}

parse_NAICS <- function(codeAbbrev = "NAICS", turtlePath = "./data/Turtle"){
  dir.create(turtlePath, recursive=TRUE)
  versions = get_classification_versions(codeAbbrev)

  for (item in versions){
    dataDir = paste0("./data/",codeAbbrev,"/", item$version)

    dir.create(dataDir, recursive=TRUE)
    filePath = paste0(dataDir, "/", item$dataFile)
    if (!file.exists(filePath)){
      download.file(item$url, filePath)
    }
    wb <- loadWorkbook(paste0(dataDir, "/", item$dataFile))
    ws = readWorksheet(wb, 1)
    colnames(ws) = strsplit(item$colnames, ",")[[1]]

    # remove NA rows (1st row)
    ws = ws[which(!is.na(ws[,1])),]

    write_NAICS_to_RDF(ws, codeAbbrev, item$version, dataDir, turtlePath)
  }
}
