get_Prefixes <- function(){
  prefixes = "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
  return(prefixes)
}

append_Prefixes <- function(queryString){
  return(paste(get_Prefixes(), queryString))
}

run_Query <- function(ontStore, queryString){
  queryString = append_Prefixes(queryString)
  results = sparql.rdf(ontStore, queryString)
  results = as.data.frame(results)
  return(results)
}

get_Concept_Count <- function(ontStore){
  queryString = "select (count(*) as ?conceptCount) where { ?concept rdf:type skos:Concept }"
  results = run_Query(ontStore, queryString)
  return(as.numeric(results$conceptCount))
}

get_Schemes <- function(ontStore){
  queryString = "select distinct ?scheme where { ?concept skos:inScheme ?scheme }"
  results = run_Query(ontStore, queryString)
  return(sort(clean_URLs(results$scheme)))
}

clean_URLs <- function(urls){
  urls = gsub("http://isdata.org/Classifications/", "", urls)
  return(urls)
}

expand_URL <- function(url){
  baseURL = "http://isdata.org/Classifications/"
  if (!grepl(baseURL, url)){
    url = paste0(baseURL, url)
  }
  return(url)
}

get_Broader_Concepts_In_Scheme <- function(ontStore, scheme){
  scheme = expand_URL(scheme)
  queryString = paste0("select ?concept ?broaderConcept where {
                                  ?concept skos:inScheme <",scheme,"> .
                                  ?concept skos:broader ?broaderConcept .
                                  }")
  results = run_Query(ontStore, queryString)
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
  results = run_Query(ontStore, queryString)
  results$concept = clean_URLs(results$concept)
  results$narrowerConcept = clean_URLs(results$narrowerConcept)
  return(results)
}

get_All_Concepts_In_Scheme <- function(ontStore, scheme){
  scheme = expand_URL(scheme)
  queryString = paste0("select ?concept where {
                                  ?concept skos:inScheme <",scheme,"> .
                                    }")
  results = run_Query(ontStore, queryString)
  results$concept = clean_URLs(results$concept)
  return(sort(results$concept))
}
