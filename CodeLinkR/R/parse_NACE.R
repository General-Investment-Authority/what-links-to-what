write_NACE_to_RDF <- function(ws, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/NACE/", version, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Order[i])

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "rdf:type",
               object = "skos:Concept")

    higherCodeURL = ""
    if (ws$Parent[i] != ""){
      loc = which(ws$Code == ws$Parent[i])
      higherCodeURL = paste0(baseURL, ws$Order[loc])
    }

    if (higherCodeURL != ""){
      add.triple(ontStore,
                 subject=higherCodeURL,
                 predicate = "skos:narrower",
                 object = subjectURL)

      add.triple(ontStore,
                 subject=subjectURL,
                 predicate = "skos:broader",
                 object = higherCodeURL)
    }

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "skos:inScheme",
               object = baseURL)


    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "skos:altLabel",
                    data = as.character(ws$Order[i]))

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "skos:notation",
                    data = ws$Code[i])

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "skos:prefLabel",
                    data = ws$Code[i])

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "skos:description",
                    data = ws$Description[i])

    ###
    alsoIncludes = paste(ws$This_item_includes[i], ws$This_item_also_includes[i])
    if (alsoIncludes != ""){
      add.data.triple(ontStore,
                      subject=subjectURL,
                      predicate = "skos:example",
                      data = alsoIncludes)
    }

    if (ws$This_item_excludes[i] != ""){
      add.data.triple(ontStore,
                      subject=subjectURL,
                      predicate = "skos:scopeNote",
                      data = ws$This_item_excludes[i])
    }
  }

  save.rdf(ontStore, paste0(turtlePath, "/NACE", version, ".turtle"), format="TURTLE")
}

parse_NACE <- function(turtlePath = "./data/Turtle"){
  dir.create(turtlePath, recursive=TRUE)
  versions = get_classification_versions("NACE")

  for (item in versions){
    dataDir = paste0("./data/NACE/", item$version)

    dir.create(dataDir, recursive=TRUE)
    filePath = paste0(dataDir, "/", item$dataFile)
    if (!file.exists(filePath)){
      download.file(item$url, filePath)
    }

    ws = read.csv(filePath, sep=";")
    colnames(ws) = strsplit(item$colnames, ",")[[1]]
    write_NACE_to_RDF(ws, item$version, dataDir, turtlePath)
  }
}
