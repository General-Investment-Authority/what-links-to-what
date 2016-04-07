write_to_Elasticsearch <- function(outputFile = "Elasticsearch.json"){
  df = download_All_Data()
  fileConn<-file(outputFile, open="a")
  for (i in c(1:nrow(df))){
    createText = paste0('{ "create" : { "_index" : "classifications", "_type" : "classification", "_id" : "',df$concept[i],'" } }')
    dataText = toJSON(df[i,])
    writeLines(createText, fileConn)
    writeLines(dataText, fileConn)
  }
  close(fileConn)
  # To reload:
  # curl -XDELETE 'http://localhost:9200/classifications/'
  # curl -XPUT 'http://localhost:9200/classifications'
  # curl -XPOST 'http://localhost:9200/_bulk' --data-binary @Elasticsearch.json
}

