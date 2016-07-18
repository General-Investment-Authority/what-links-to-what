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

    write_Code1_to_Code2_to_RDF(ws, versionsAbbrev, item$classification1, item$classification2, turtlePath)
  }
}



