link_CN_to_CPA <- function(concordanceAbbrev = "CN_to_CPA", turtlePath = "./data/Turtle"){

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
    ws = readWorksheet(wb, 1)
    colnames(ws) = strsplit(item$colnames, ",")[[1]]


    # some of these codes are weird, not sure how to process them: "23SS", "23VV", "SSSS"
    # fix CPA codes to standard format: 00.00.00
    # only fix if between 5 and 6 numbers, and no letters
    locs = which(grepl("[0-9]{5,6}", ws$Code2))
    ws$Code2[locs] = unlist(lapply(ws$Code2[locs],
                                   FUN=function(x){
                                     paste0(substring(x, 1,2),
                                            ".",
                                            substring(x, 3,4),
                                            ".",
                                            substring(x, 5))}))

    write_Code1_to_Code2_to_RDF(ws, versionsAbbrev, item$classification1, item$classification2, turtlePath)
  }
}
