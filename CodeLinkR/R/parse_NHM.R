write_NHM_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Code[i])

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
               object = "http://www.w3.org/2004/02/skos/core#Concept")

    # the higher code is found by going from right to left and switching non-zero numbers to zero
    # and seeing if there is a match
    keepSearching = TRUE
    higherCode = ws$Code[i]
    higherCodeURL = ""
    while(keepSearching){
      oldHigherCode = higherCode
      higherCode = str_replace(higherCode, "[1-9](0*)$", "0\\1")
      if ((higherCode == oldHigherCode) | (grepl("[1-9]", higherCode) == FALSE)) {
        keepSearching = FALSE
      }
      higherCodeLoc = which(ws$Code == higherCode)
      if (any(higherCodeLoc)){
        keepSearching = FALSE
        higherCodeURL = paste0(baseURL, ws$Code[higherCodeLoc])
      }
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

parse_NHM <- function(codeAbbrev = "NHM", turtlePath = "./data/Turtle"){
  dir.create(turtlePath, recursive=TRUE)
  versions = get_classification_versions(codeAbbrev)

  for (item in versions){

    dataDir = paste0("./data/",codeAbbrev,"/", item$version)

    dir.create(dataDir, recursive=TRUE)
    fileName = tail(strsplit(item$url, "/")[[1]], n=1)
    filePath = paste0(dataDir, "/", fileName)
    if (!file.exists(filePath)){
      download.file(item$url, filePath)
    }
    unzip(filePath, exdir=dataDir)
    wb <- loadWorkbook(paste0(dataDir, "/", item$dataFile))
    ws = readWorksheet(wb, 1)
    colnames(ws) = strsplit(item$colnames, ",")[[1]]
    write_NHM_to_RDF(ws, codeAbbrev, item$version, dataDir, turtlePath)
  }

}
