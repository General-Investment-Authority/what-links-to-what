write_CN_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  # add rdf:type skos:ConceptScheme
  add.triple(ontStore,
             subject = substring(baseURL, 1, nchar(baseURL)-1),
             predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
             object = "http://www.w3.org/2004/02/skos/core#skos:ConceptScheme")

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, gsub(" ", "", ws$CN_Code[i]))

    add.triple(ontStore,
               subject = subjectURL,
               predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
               object = "http://www.w3.org/2004/02/skos/core#Concept")

    higherCodeURL = ""

    if (grepl("^[0-9]", ws$CN_Code[i])){
      if (nchar(ws$CN_Code[i]) == 4){
        # look for the right chapter
        # Make sure to include the ' ' when searching - non-breakable space?
        loc = which(ws$CN_Code == paste0("CHAPTER ", substring(ws$CN_Code[i],1,2)))
        if (any(loc)){
          higherCodeURL = paste0(baseURL, ws$CN_Code[loc])
        }
      } else if (nchar(ws$CN_Code[i]) > 4){
        tmp = strsplit(ws$CN_Code[i], " ")[[1]]
        higherCode = paste(tmp[c(1:(length(tmp)-1))], collapse=" ")

        higherCodeLoc = which(ws$CN_Code == higherCode)
        if (!any(higherCodeLoc)){
          higherCode = paste(tmp[c(1:(length(tmp)-2))], collapse=" ")
          higherCodeLoc = which(ws$CN_Code == higherCode)
        }

        if (any(higherCodeLoc)){
          higherCodeURL = paste0(baseURL, ws$CN_Code[higherCodeLoc])
        }
      }
    } else if (grepl("^CHAPTER", ws$CN_Code[i])){
      # just use the heading above
      higherCodeURL = paste0(baseURL, ws$CN_Code[i-1])
    }

    if (higherCodeURL != ""){
      higherCodeURL = gsub(" ", "", higherCodeURL)
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
                    data = ws$Sorting_Key[i])

    code = ws$CN_Code[i]
    if (grepl("^[0-9]", code)){
      code = gsub(" ", "", code)
    }
    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "http://www.w3.org/2004/02/skos/core#notation",
                    data = code)

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "http://www.w3.org/2004/02/skos/core#prefLabel",
                    data = ws$CN_Code[i])

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "http://www.w3.org/2004/02/skos/core#description",
                    data = ws$EN[i])
  }

  save.rdf(ontStore, paste0(turtlePath, "/", codeAbbrev, version, ".turtle"), format="TURTLE")
}


parse_CN <- function(codeAbbrev = "CN", turtlePath = "./data/Turtle"){
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
    write_CN_to_RDF(ws, codeAbbrev, item$version, dataDir, turtlePath)
  }
}
