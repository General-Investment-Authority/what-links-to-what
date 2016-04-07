write_NACE_to_NAICS_to_RDF <- function(ws, versionsAbbrev, classification1, classification2, turtlePath){
  baseURL1 = paste0("http://isdata.org/Classifications/",classification1, "/")
  baseURL2 = paste0("http://isdata.org/Classifications/",classification2, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(ws))){
    url1 = paste0(baseURL1, ws$Code1[i])
    url2 = paste0(baseURL2, ws$Code2[i])

    add.triple(ontStore,
               subject=url1,
               predicate = "http://www.w3.org/2004/02/skos/core#relatedMatch",
               object = url2)

    add.triple(ontStore,
               subject=url2,
               predicate = "http://www.w3.org/2004/02/skos/core#relatedMatch",
               object = url1)

  }
  save.rdf(ontStore, paste0(turtlePath, "/", versionsAbbrev, ".turtle"), format="TURTLE")
}

link_NACE_to_NAICS <- function(concordanceAbbrev = "NACE_to_NAICS", turtlePath = "./data/Turtle"){

  dir.create(turtlePath, recursive=TRUE)
  versions = get_concordance_versions(concordanceAbbrev)

  for (item in versions){
    versionsAbbrev = paste0(gsub("/", "", item$classification1), "_to_", gsub("/", "", item$classification2))

    dataDir = paste0("./data/",concordanceAbbrev,"/", versionsAbbrev)

    dir.create(dataDir, recursive=TRUE)

    fileName = tail(strsplit(item$url, "/")[[1]], n=1)
    filePath = paste0(dataDir, "/", fileName)
    if (!file.exists(filePath)){
      download.file(item$url, filePath)
    }
    unzip(filePath, exdir = dataDir)

    # from the readxl package.  Can't use XLConnect since this is in Excel 5.0/7.0
    # "org.apache.poi.hssf.OldExcelFormatException:
    # The supplied spreadsheet seems to be Excel 5.0/7.0 (BIFF5) format.
    # POI only supports BIFF8 format (from Excel versions 97/2000/XP/2003)"
    ws <- read_excel(path = paste0(dataDir, "/", item$dataFile), sheet =1)
    colnames(ws) = strsplit(item$colnames, ",")[[1]]

    write_NACE_to_NAICS_to_RDF(ws, versionsAbbrev, item$classification1, item$classification2, turtlePath)
  }
}



