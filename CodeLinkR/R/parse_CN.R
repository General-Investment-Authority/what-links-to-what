write_CN_to_RDF <- function(cn, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/CN/", version, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(cn))){
    subjectURL = paste0(baseURL, cn$Sorting_Key[i])

    add.triple(ontStore,
               subject=subjectURL,
               predicate = "rdf:type",
               object = "skos:Concept")


    higherCodeURL = ""

    if (grepl("^[0-9]", cn$CN_Code[i])){
      if (nchar(cn$CN_Code[i]) == 4){
        # just use the heading above
        higherCodeURL = paste0(baseURL, cn$Sorting_Key[i-1])
      } else if (nchar(cn$CN_Code[i]) > 4){
        tmp = strsplit(cn$CN_Code[i], " ")[[1]]
        higherCode = paste(tmp[c(1:(length(tmp)-1))], collapse=" ")

        higherCodeLoc = which(cn$CN_Code == higherCode)
        if (!any(higherCodeLoc)){
          higherCode = paste(tmp[c(1:(length(tmp)-2))], collapse=" ")
          higherCodeLoc = which(cn$CN_Code == higherCode)
        }

        if (any(higherCodeLoc)){
          higherCodeURL = paste0(baseURL, cn$Sorting_Key[higherCodeLoc])
        }
      }
    } else if (grepl("^CHAPTER", cn$CN_Code[i])){
      # just use the heading above
      higherCodeURL = paste0(baseURL, cn$Sorting_Key[i-1])
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
                    data = cn$Sorting_Key[i])

    code = cn$CN_Code[i]
    if (grepl("^[0-9]", code)){
      code = gsub(" ", "", code)
    }
    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "skos:notation",
                    data = code)

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "skos:prefLabel",
                    data = cn$CN_Code[i])

    add.data.triple(ontStore,
                    subject=subjectURL,
                    predicate = "skos:description",
                    data = cn$EN[i])
  }

  save.rdf(ontStore, paste0(turtlePath, "/CN", version, ".turtle"), format="TURTLE")
}


parse_CN <- function(turtlePath = "./data/Turtle"){
  dir.create(turtlePath, recursive=TRUE)
  versions = get_classification_versions("CN")

  for (item in versions){
    dataDir = paste0("./data/CN/", item$version)

    dir.create(dataDir, recursive=TRUE)
    fileName = tail(strsplit(item$url, "/")[[1]], n=1)
    filePath = paste0(dataDir, "/", fileName)
    if (!file.exists(filePath)){
      download.file(item$url, filePath)
    }
    unzip(filePath, exdir=dataDir)
    wb <- loadWorkbook(paste0(dataDir, "/", item$dataFile))
    cn = readWorksheet(wb, 1)
    colnames(cn) = strsplit(item$colnames, ",")[[1]]
    write_CN_to_RDF(cn, item$version, dataDir, turtlePath)
  }
}
