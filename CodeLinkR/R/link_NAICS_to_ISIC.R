link_NAICS_to_ISIC <- function(concordanceAbbrev = "NAICS_to_ISIC", turtlePath = "./data/Turtle"){

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
    unzip(filePath, exdir=dataDir)

    wb <- loadWorkbook(paste0(dataDir, "/", item$dataFile))
    ws = readWorksheet(wb, 2) # need to read 2nd worksheet
    colnames(ws) = strsplit(item$colnames, ",")[[1]]

    write_Code1_to_Code2_to_RDF(ws, versionsAbbrev, item$classification1, item$classification2, turtlePath)
  }
}
