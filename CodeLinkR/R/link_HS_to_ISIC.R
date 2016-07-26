link_HS_to_ISIC <- function(concordanceAbbrev = "HS_to_ISIC", turtlePath = "./data/Turtle"){

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

    ws = read.csv(paste0(dataDir, "/", item$dataFile), sep=",")
    colnames(ws) = strsplit(item$colnames, ",")[[1]]

    # need to fix up all HS codes - six digits, pad with zero on left if missing
    ws$Code1 = sprintf("%06d", ws$Code1)
    # last two digits are decimals
    ws$Code1 = unlist(lapply(ws$Code1, function(x){paste0(substring(x, 1, 4), ".", substring(x,5,6))}))

    write_Code1_to_Code2_to_RDF(ws, versionsAbbrev, item$classification1, item$classification2, turtlePath)
  }
}


