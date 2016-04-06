write_SITC_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(ws))){
    print(i)
    subjectURL = paste0(baseURL, ws$Code[i])

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "rdf:type",
               object = "skos:Concept")


    # the higher code is found by chopping off characters starting from the right
    # and finding the first code that matches
    keepSearching = TRUE
    higherCode = ws$Code[i]
    higherCodeURL = ""
    while(keepSearching){
      higherCode = substring(higherCode, 1,nchar(higherCode)-1)
      higherCodeLoc = which(ws$Code == higherCode)
      if (any(higherCodeLoc)){
        keepSearching = FALSE
        higherCodeURL = paste0(baseURL, ws$Code[higherCodeLoc])
      }
      if (nchar(higherCode) <= 1){
        keepSearching = FALSE
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

    if (!is.na(ws$Description[i])){
      add.data.triple(ontStore,
                      subject=subjectURL,
                      predicate = "skos:description",
                      data = ws$Description[i])

    }
  }

  save.rdf(ontStore, paste0(turtlePath, "/", codeAbbrev, version, ".turtle"), format="TURTLE")
}

parse_SITC <- function(codeAbbrev = "SITC", turtlePath = "./data/Turtle"){
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
    ws = read.csv(paste0(dataDir, "/", item$dataFile), sep="\t")
    colnames(ws) = strsplit(item$colnames, ",")[[1]]
    # boo, invalid multibyte string
    ws$Code = iconv(ws$Code, from="UTF-8", to="UTF-8")
    ws$Description = iconv(ws$Description, from="UTF-8", to="UTF-8")
    # get rid of NA codes
    ws = ws[which(!is.na(ws$Code)),]

    # deal with ellipses - prepend text from parent category where this happens
    fixLocs = which(grepl("^\\.\\.\\.\\.", ws$Description))
    parentsOfFixLocs = gsub("\\.*[0-9]$", "", ws$Code[fixLocs])
    for (i in c(1:length(fixLocs))){
      ws$Description[fixLocs[i]] = paste(ws$Description[which(ws$Code == parentsOfFixLocs[i])], ws$Description[fixLocs[i]])
    }
    write_SITC_to_RDF(ws, codeAbbrev, item$version, dataDir, turtlePath)
  }
}
