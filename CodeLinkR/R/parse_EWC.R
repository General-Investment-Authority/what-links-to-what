write_EWC_to_RDF <- function(ws_examples, ws_classification, codeAbbrev, version, dataDir, turtlePath){

  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  # add rdf:type skos:ConceptScheme
  add_skos_concept_scheme(ontStore, substring(baseURL, 1, nchar(baseURL)-1))

  process_examples(ontStore, ws_examples, baseURL)

  process_classification(ontStore, ws_classification, baseURL)

  save.rdf(ontStore, paste0(turtlePath, "/", codeAbbrev, version, ".turtle"), format="TURTLE")
}

process_classification <- function(ontStore, ws_classification, baseURL){
  for (i in c(1:nrow(ws_classification))){
    subjectURL = paste0(baseURL, gsub(" ", "_", ws_examples$Code[i]))

    # just need Code and Description columns
    code = ws_classification$Code[i]
    parentCode = paste(head(strsplit(code, " ")[[1]], -1), collapse=" ")
    if (parentCode != ""){
      higherCodeURL = paste0(baseURL, gsub(" ", "_", parentCode))

      add_skos_narrower(ontStore, higherCodeURL, subjectURL)
      add_skos_broader(ontStore, subjectURL, higherCodeURL)
    }


    add_skos_concept_node(ontStore,
                          conceptId = subjectURL,
                          notation = ws_classification$Code[i],
                          description = ws_classification$Description[i],
                          prefLabel = ws_classification$Code[i])
  }
}

process_examples <- function(ontStore, ws_examples, baseURL){

  # need to reshape things - can be multiple codes on one line
  new_ws_examples = c()
  for (i in c(1:nrow(ws_examples))){
    new_ws_examples = rbind(new_ws_examples, cbind(ws_examples$Waste[i], strsplit(ws_examples$Codes[i], ", ")[[1]]))
  }
  new_ws_examples = as.data.frame(new_ws_examples)
  colnames(new_ws_examples) = c("Example", "Code")
  ws_examples = new_ws_examples
  rm(new_ws_examples)

  for (i in c(1:nrow(ws_examples))){
    subjectURL = paste0(baseURL, gsub(" ", "_", ws_examples$Code[i]))
    add_skos_example(ontStore, subjectURL, ws_examples$Example[i])
  }
}

write_EWC_to_RDF <- function(ws, codeAbbrev, version, dataDir, turtlePath){
  baseURL = paste0("http://isdata.org/Classifications/",codeAbbrev,"/", version, "/")

  ontStore = initialize_New_OntStore()

  # add rdf:type skos:ConceptScheme
  add_skos_concept_scheme(ontStore, substring(baseURL, 1, nchar(baseURL)-1))

  locs = which(is.na(ws$Description))
  if (any(locs)){
    ws$Description[locs] = ""
  }

  for (i in c(1:nrow(ws))){
    subjectURL = paste0(baseURL, ws$Code[i])

    # the higher code is found by chopping off characters starting from the right
    # and finding the first code that matches
    keepSearching = TRUE
    higherCode = gsub("\\.", "", ws$Code[i])
    higherCodeURL = ""
    while(keepSearching){
      higherCode = substring(higherCode, 1,nchar(higherCode)-1)
      higherCodeLoc = which(gsub("\\.", "", ws$Code[i]) == higherCode)
      if (any(higherCodeLoc)){
        keepSearching = FALSE
        higherCodeURL = paste0(baseURL, gsub("\\.", "", ws$Code[higherCodeLoc]))
      }
      if (nchar(higherCode) <= 1){
        keepSearching = FALSE
      }
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

parse_EWC <- function(codeAbbrev = "EWC", turtlePath = "./data/Turtle"){
  dir.create(turtlePath, recursive=TRUE)
  versions = get_classification_versions(codeAbbrev)

  # Two different files are used
  # LoW_Waste_Thesaurus.txt
  # LoW_Classification.txt

  ws_examples = c()
  ws_classification = c()

  for (item in versions){
    dataDir = paste0("./data/",codeAbbrev,"/", item$version)

    dir.create(dataDir, recursive=TRUE)

    ws = read.csv(item$dataFile, sep="\t", header=FALSE)

    colnames(ws) = strsplit(item$colnames, ",")[[1]]

    if (grepl("LoW_Waste_Thesaurus", item$dataFile)){
      ws_examples = ws
    } else {
      ws_classification = ws
    }
  }

  write_EWC_to_RDF(ws_examples, ws_classification, codeAbbrev, item$version, dataDir, turtlePath)
}
