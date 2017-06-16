get_Prefixes <- function(){
  prefixes = "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
  return(prefixes)
}

append_Prefixes <- function(queryString){
  return(paste(get_Prefixes(), queryString, '\n'))
}

clean_URLs <- function(urls){
  urls = gsub("http://isdata.org/Classifications/", "", urls)
  urls = gsub("<|>", "", urls)
  return(urls)
}

expand_URL <- function(url){
  baseURL = "http://isdata.org/Classifications/"
  if (!grepl(baseURL, url)){
    url = paste0(baseURL, url)
  }
  return(url)
}

get_Number_of_Links_Between_Schemes <- function(endpoint){
  queryString = append_Prefixes("select (count(*) as ?linkCount) ?scheme1 ?relation ?scheme2 where {
                    ?concept1 rdf:type skos:Concept .
                    ?concept1 skos:inScheme ?scheme1 .
                     ?concept2 rdf:type skos:Concept .
                     ?concept2 skos:inScheme ?scheme2 .
                     filter(?scheme1 != ?scheme2) .
                     ?concept1 ?relation ?concept2 .
                    FILTER(?relation = skos:relatedMatch || ?relation = skos:exactMatch || ?relation = skos:broadMatch || ?relation = skos:narrowMatch) .
                   } group by ?scheme1 ?relation ?scheme2")
  queryResults = SPARQL(url=endpoint, query=queryString)
  df = queryResults$results
  return(df)
}

get_Concept_Count <- function(endpoint){
  queryString = append_Prefixes("select (count(*) as ?conceptCount) where { ?concept rdf:type skos:Concept }")
  queryResults = SPARQL(url=endpoint, query=queryString)
  results = queryResults$results
  return(as.numeric(results$conceptCount))
}

get_Schemes <- function(endpoint){
  queryString = append_Prefixes("select distinct ?scheme where { ?concept skos:inScheme ?scheme }")
  queryResults = SPARQL(url=endpoint, query=queryString)
  results = as.character(queryResults$results)
  return(sort(clean_URLs(results)))
}


get_Broader_Concepts_In_Scheme <- function(ontStore, scheme){
  scheme = expand_URL(scheme)
  queryString = paste0("select ?concept ?broaderConcept where {
                                  ?concept skos:inScheme <",scheme,"> .
                                  ?concept skos:broader ?broaderConcept .
                                  }")
  queryResults = SPARQL(url=endpoint, query=queryString, format='csv', extra=list(format='text/csv', Accept='text/csv'))
  results = queryResults$results
  results$concept = clean_URLs(results$concept)
  results$broaderConcept = clean_URLs(results$broaderConcept)
  return(results)
}

get_Narrower_Concepts_In_Scheme <- function(ontStore, scheme){
  scheme = expand_URL(scheme)
  queryString = paste0("select ?concept ?narrowerConcept where {
                                  ?concept skos:inScheme <",scheme,"> .
                                  ?concept skos:narrower ?narrowerConcept .
                                  }")
  queryResults = SPARQL(url=endpoint, query=queryString, format='csv', extra=list(format='text/csv', Accept='text/csv'))
  results = queryResults$results
  results$concept = clean_URLs(results$concept)
  results$narrowerConcept = clean_URLs(results$narrowerConcept)
  return(results)
}

get_All_Concepts_In_Scheme <- function(ontStore, scheme){
  scheme = expand_URL(scheme)
  queryString = paste0("select ?concept where {
                                  ?concept skos:inScheme <",scheme,"> .
                                    }")

  queryResults = SPARQL(url=endpoint, query=queryString, format='csv', extra=list(format='text/csv', Accept='text/csv'))
  results = queryResults$results
  results$concept = clean_URLs(results$concept)
  return(sort(results$concept))
}

download_All_Data <- function(endpoint){
  queryString = "select * where {
                    ?concept rdf:type skos:Concept .
                    ?concept skos:inScheme ?scheme .
                    ?concept skos:notation ?notation .
                    ?concept skos:prefLabel ?prefLabel .
                    ?concept skos:description ?description .
                    OPTIONAL{?concept skos:example ?example }.
                    OPTIONAL{?concept skos:scopeNote ?scopeNote }.
                }"
  queryResults = SPARQL(url=endpoint, query=queryString, format='csv', extra=list(format='text/csv', Accept='text/csv'))
  df = queryResults$results
  return(df)
}
