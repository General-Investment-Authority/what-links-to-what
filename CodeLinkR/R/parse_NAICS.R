write_NAICS_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Code[i])

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "rdf:type",
               object = "skos:Concept")

    higherCodeURL = ""

    loc = which(ws$Code == substr(ws$Code[i], 1, nchar(ws$Code[i])-1))
    if (any(loc)){
      higherCodeURL = paste0(baseURL, ws$Code[loc])
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
                    data = ws$Title[i])
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
