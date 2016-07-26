write_ISIC_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
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
                          description = ws$Description[i],
                          prefLabel = ws$Code[i])
  }

  save.rdf(ontStore, paste0(turtlePath, "/", codeAbbrev, version, ".turtle"), format="TURTLE")
}

parse_ISIC <- function(codeAbbrev = "ISIC", turtlePath = "./data/Turtle"){
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

    # default
    if (item$version == "3"){  # version 3 is fixed width delimited
      ws = read.fwf(paste0(dataDir, "/", item$dataFile), widths=c(4,500), skip=1)
      # delete an empty row too
      ws = ws[which(!is.na(ws$V1)),]
    } else { # all other versions are comma delimited
      ws = read.csv(paste0(dataDir, "/", item$dataFile), sep=",")
    }

    colnames(ws) = strsplit(item$colnames, ",")[[1]]

    ws$Code = trim(ws$Code)
    ws$Description = trim(ws$Description)

    write_ISIC_to_RDF(ws, codeAbbrev, item$version, dataDir, turtlePath)
  }
}
