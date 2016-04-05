write_Harmonized_System_to_RDF <- function(ws, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/HarmonizedSystem/", version, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Code[i])

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "rdf:type",
               object = "skos:Concept")

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
  }

  save.rdf(ontStore, paste0(turtlePath, "/HarmonizedSystem", version, ".turtle"), format="TURTLE")
}

parse_Harmonized_System <- function(turtlePath){
  dir.create(turtlePath)
  versions = get_classification_versions("Harmonized System")

  for (item in versions){
    dir.create(item$dataDir, recursive=TRUE)
    fileName = tail(strsplit(item$url, "/")[[1]], n=1)
    filePath = paste0(item$dataDir, "/", fileName)
    if (!file.exists(filePath)){
      download.file(item$url, filePath)
    }
    unzip(filePath, exdir=item$dataDir)
    wb <- loadWorkbook(paste0(item$dataDir, "/", item$dataFile))
    ws = readWorksheet(wb, 1)
    colnames(ws) = strsplit(item$colnames, ",")[[1]]
    write_Harmonized_System_to_RDF(ws, item$version, item$dataDir, turtlePath)
  }

}
