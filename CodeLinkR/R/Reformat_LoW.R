reformat_LoW <- function(){

  options(stringsAsFactors = FALSE)

  library(dplyr)

  examples = "/home/cbdavis/Desktop/svn/what-links-to-what/CodeLinkR/inst/classifications/EWC/LoW_Examples.txt"
  thesaurus = "/home/cbdavis/Desktop/svn/what-links-to-what/CodeLinkR/inst/classifications/EWC/LoW_Waste_Thesaurus.txt"

  df = read.csv(thesaurus, sep="\t", header=FALSE)
  colnames(df) = c("Waste", "Codes")
  newDF2 = c()
  for (i in c(1:nrow(df))){
    print(i)
    if (df$Codes[i] != ""){
      codes = strsplit(df$Codes[i], ", ")[[1]]
      tmp = cbind(df$Waste[i], codes)
      colnames(tmp) = c("Waste", "Codes")
      newDF2 = rbind(newDF2, tmp)
    }
  }



  examplesAndCodes = as.data.frame(newDF2)
  colnames(examplesAndCodes) = c("Example", "Code")
  examplesAndCodes = examplesAndCodes[which(!duplicated(examplesAndCodes)),]
  examplesAndCodes = examplesAndCodes[which(examplesAndCodes$Example != ""),]
  examplesAndCodes = examplesAndCodes[,c(2,1)]

  examplesAndCodes = examplesAndCodes %>% arrange(Code, Example)

  # write back to file
  write.table(examplesAndCodes, file="/home/cbdavis/Dropbox/IS Data/Databases/LOW/LoW_Cleaned_Examples.txt", sep="\t", row.names = FALSE)
}
