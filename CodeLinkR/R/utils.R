trim <- function(text){
  text = gsub("[ |\n]*$", "", text)
  return(text)
}

determine_skos_linking_predicate <- function(codes1, codes2, index){
  numCode1 = length(which(codes1 == codes1[index]))
  numCode2 = length(which(codes2 == codes2[index]))

  # default predicate for when we don't know what we're looking at
  linkingPredicate_code1_code2 = "http://www.w3.org/2004/02/skos/core#relatedMatch"
  linkingPredicate_code2_code1 = "http://www.w3.org/2004/02/skos/core#relatedMatch"

  if (numCode1 == numCode2){
    linkingPredicate_code1_code2 = "http://www.w3.org/2004/02/skos/core#exactMatch"
    linkingPredicate_code2_code1 = "http://www.w3.org/2004/02/skos/core#exactMatch"
  } else if (numCode1 == 1 & numCode2 > 1){
    linkingPredicate_code1_code2 = "http://www.w3.org/2004/02/skos/core#narrowMatch"
    linkingPredicate_code2_code1 = "http://www.w3.org/2004/02/skos/core#broadMatch"
  } else if (numCode1 > 1 & numCode2 == 1){
    linkingPredicate_code1_code2 = "http://www.w3.org/2004/02/skos/core#broadMatch"
    linkingPredicate_code2_code1 = "http://www.w3.org/2004/02/skos/core#narrowMatch"
  } # otherwise there's some sort of overlap between the codes - many to many mapping

  return(c(linkingPredicate_code1_code2, linkingPredicate_code2_code1))
}

write_Code1_to_Code2_to_RDF <- function(ws, versionsAbbrev, classification1, classification2, turtlePath){
  baseURL1 = paste0("http://isdata.org/Classifications/",classification1, "/")
  baseURL2 = paste0("http://isdata.org/Classifications/",classification2, "/")

  ontStore = initialize_New_OntStore()

  for (i in c(1:nrow(ws))){
    if (ws$Code1[i] != 0){
      #replacement of periods found in link_HS_to_SITC.R and link_ISIC_to_CPC.R
      # not sure if this is necessary
      #url1 = trim(paste0(baseURL1, gsub("\\.", "", ws$Code1[i])))
      #url2 = trim(paste0(baseURL2, gsub("\\.", "", ws$Code2[i])))

      url1 = trim(paste0(baseURL1, ws$Code1[i]))
      url2 = trim(paste0(baseURL2, ws$Code2[i]))

      linkingPredicates = determine_skos_linking_predicate(ws$Code1, ws$Code2, i)

      add.triple(ontStore,
                 subject=url1,
                 predicate = linkingPredicates[1],
                 object = url2)

      add.triple(ontStore,
                 subject=url2,
                 predicate = linkingPredicates[2],
                 object = url1)
    }
  }
  save.rdf(ontStore, paste0(turtlePath, "/", versionsAbbrev, ".turtle"), format="TURTLE")
}
