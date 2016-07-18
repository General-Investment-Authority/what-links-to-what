write_SITC_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  # add rdf:type skos:ConceptScheme
  add_skos_concept_scheme(ontStore, substring(baseURL, 1, nchar(baseURL)-1))

  locs = which(is.na(ws$Description))
  if (any(locs)){
    ws$Description[locs] = ""
  }

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Code[i])

    # the higher code is found by chopping off characters starting from the right
    # and finding the first code that matches
    keepSearching = TRUE
    higherCode = gsub("\\.", "", ws$Code[i])
    higherCodeURL = ""
    while(keepSearching){
      higherCode = substring(higherCode, 1,nchar(higherCode)-1)
      higherCodeLoc = which(gsub("\\.", "", ws$Code[i]) == higherCode)
      if (any(higherCodeLoc)){
        keepSearching = FALSE
        higherCodeURL = paste0(baseURL, gsub("\\.", "", ws$Code[higherCodeLoc]))
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
                          notation = ws$Code[i],
                          description = ws$Description[i],
                          prefLabel = ws$Code[i])
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

    # different versions have different delimiters (and file encodings)
    if (item$version == 3){
      ws = read.fwf(file=paste0(dataDir, "/", item$dataFile), widths=c(14,1e6), fileEncoding="iso-8859-1", skip=1)
    } else {
      ws = read.csv(paste0(dataDir, "/", item$dataFile), sep="\t")
    }

    colnames(ws) = strsplit(item$colnames, ",")[[1]]
    # boo, invalid multibyte string
    ws$Code = gsub(" +", "", iconv(ws$Code, from="UTF-8", to="UTF-8"))
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
