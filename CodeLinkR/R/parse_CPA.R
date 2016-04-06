write_CPA_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Code[i])

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
               object = "http://www.w3.org/2004/02/skos/core#Concept")

    higherCodeURL = ""
    if (ws$Parent[i] != ""){
      loc = which(ws$Code == ws$Parent[i])
      higherCodeURL = paste0(baseURL, ws$Code[loc])
    }

    if (higherCodeURL != ""){
      add.triple(ontStore,
                 subject=higherCodeURL,
                 predicate = "http://www.w3.org/2004/02/skos/core#narrower",
                 object = subjectURL)

      add.triple(ontStore,
                 subject=subjectURL,
                 predicate = "http://www.w3.org/2004/02/skos/core#broader",
                 object = higherCodeURL)
    }

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "http://www.w3.org/2004/02/skos/core#inScheme",
               object = substring(baseURL, 1, nchar(baseURL)-1))


    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "http://www.w3.org/2004/02/skos/core#altLabel",
                    data = as.character(ws$Order[i]))

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "http://www.w3.org/2004/02/skos/core#notation",
                    data = ws$Code[i])

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "http://www.w3.org/2004/02/skos/core#prefLabel",
                    data = ws$Code[i])

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "http://www.w3.org/2004/02/skos/core#description",
                    data = ws$Description[i])
  }

  save.rdf(ontStore, paste0(turtlePath, "/", codeAbbrev, version, ".turtle"), format="TURTLE")
}

parse_CPA <- function(codeAbbrev = "CPA", turtlePath = "./data/Turtle"){
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
    write_CPA_to_RDF(ws, codeAbbrev, item$version, dataDir, turtlePath)
  }
}
