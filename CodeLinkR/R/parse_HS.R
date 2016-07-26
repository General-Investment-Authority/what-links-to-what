write_HS_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  # add rdf:type skos:ConceptScheme
  add_skos_concept_scheme(ontStore, substring(baseURL, 1, nchar(baseURL)-1))

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$HS_CODE[i])

    # the higher code is found by chopping off characters starting from the right
    # and finding the first code that matches
    keepSearching = TRUE
    higherCode = ws$HS_CODE[i]
    higherCodeURL = ""
    while(keepSearching){
      higherCode = substring(higherCode, 1,nchar(higherCode)-1)
      higherCodeLoc = which(ws$HS_CODE == higherCode)
      if (any(higherCodeLoc)){
        keepSearching = FALSE
        higherCodeURL = paste0(baseURL, ws$HS_CODE[higherCodeLoc])
      }
      if (nchar(higherCode) <= 1){
        keepSearching = FALSE
      }
    }

    if (higherCodeURL != ""){
      add_skos_narrower(ontStore, higherCodeURL, subjectURL)
      add_skos_broader(ontStore, subjectURL, higherCodeURL)
    }

    add_skos_inScheme(ontStore, subjectURL, substring(baseURL, 1, nchar(baseURL)-1))

    add_skos_concept_node(ontStore,
                          conceptId = subjectURL,
                          notation = ws$HS_CODE[i],
                          description = ws$SE_DESC_EN[i],
                          prefLabel = ws$HS_CODE[i])
  }

  save.rdf(ontStore, paste0(turtlePath, "/", codeAbbrev, version, ".turtle"), format="TURTLE")
}

parse_HS <- function(codeAbbrev = "HS", turtlePath = "./data/Turtle"){
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

    unzip(filePath, exdir = dataDir)
    wb <- loadWorkbook(paste0(dataDir, "/", item$dataFile))
    ws = readWorksheet(wb, 1)
    colnames(ws) = strsplit(item$colnames, ",")[[1]]

    write_HS_to_RDF(ws, codeAbbrev, item$version, dataDir, turtlePath)
  }

}
