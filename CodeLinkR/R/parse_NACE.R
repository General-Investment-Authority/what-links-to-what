write_NACE_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  # add rdf:type skos:ConceptScheme
  add_skos_concept_scheme(ontStore, substring(baseURL, 1, nchar(baseURL)-1))

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Code[i])

    higherCodeURL = ""
    if (ws$Parent[i] != ""){
      loc = which(ws$Code == ws$Parent[i])
      higherCodeURL = paste0(baseURL, ws$Code[loc])
    }

    if (higherCodeURL != ""){
      add_skos_narrower(ontStore, higherCodeURL, subjectURL)
      add_skos_broader(ontStore, subjectURL, higherCodeURL)
    }

    add_skos_inScheme(ontStore, subjectURL, substring(baseURL, 1, nchar(baseURL)-1))

    alsoIncludes = paste(ws$This_item_includes[i], ws$This_item_also_includes[i])

    add_skos_concept_node(ontStore,
                          conceptId = subjectURL,
                          notation = ws$Code[i],
                          description = ws$Description[i],
                          prefLabel = ws$Code[i],
                          altLabel = as.character(ws$Order[i]),
                          example = alsoIncludes,
                          scopeNote = ws$This_item_excludes[i])
  }

  save.rdf(ontStore, paste0(turtlePath, "/", codeAbbrev, version, ".turtle"), format="TURTLE")
}

parse_NACE <- function(codeAbbrev = "NACE", turtlePath = "./data/Turtle"){
  dir.create(turtlePath, recursive=TRUE)
  versions = get_classification_versions(codeAbbrev)

  for (item in versions){
    dataDir = paste0("./data/",codeAbbrev,"/", item$version)

    dir.create(dataDir, recursive=TRUE)
    filePath = paste0(dataDir, "/", item$dataFile)
    if (!file.exists(filePath)){
      download.file(item$url, filePath)
    }

    ws = read.csv(filePath, sep=";")
    colnames(ws) = strsplit(item$colnames, ",")[[1]]
    write_NACE_to_RDF(ws, codeAbbrev, item$version, dataDir, turtlePath)
  }
}
