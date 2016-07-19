# -*- coding: utf-8 -*-
"""
Created on Mon Jul 18 09:01:52 2016

@author: cbdavis
"""

import csv


import glob
from rdflib import Graph

prefixes = """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
"""

turtleFiles = glob.glob('/home/cbdavis/Desktop/svn/what-links-to-what/CodeLinkR/data/Turtle/*.turtle')

g = Graph()
for turtleFile in turtleFiles:
    print turtleFile
    g.load(turtleFile, format="turtle")

################# Bulk import Neo4j #################

query_result = g.query(prefixes + 
"""
    select * where {
        ?x rdf:type skos:Concept . 
        OPTIONAL {?x skos:notation ?notation} .
        OPTIONAL {?x skos:description ?description} .
        OPTIONAL {?x skos:prefLabel ?prefLabel} .
        OPTIONAL {?x skos:altLabel ?altLabel} .
        OPTIONAL {?x skos:example ?example} .
        OPTIONAL {?x skos:scopeNote ?scopeNote} .
    }
""")

with open('/home/cbdavis/Desktop/neo4j_skos_concepts.csv', 'wb') as csvfile:
    neo4jwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    
    headerValues = ['conceptId:ID', 'notation:string', 'description:string', 'prefLabel:string', 'altLabel:string', 'example:string', 'scopeNote:string', ':LABEL']
    neo4jwriter.writerow(headerValues)
    
    for row in query_result:
        rowValues = [row['x'], row['notation'], row['description'], row['prefLabel'], row['altLabel'], row['example'], row['scopeNote'], 'Concept']
        rowValues = ['' if x is None else str(x.encode('utf-8')) for x in rowValues]
        rowValues[0] = '`' + rowValues[0] + '`'
        neo4jwriter.writerow(rowValues)


query_result = g.query(prefixes + """
    select ?x where {
        ?x rdf:type skos:ConceptScheme . 
    }
""")

with open('/home/cbdavis/Desktop/neo4j_skos_concept_schemes.csv', 'wb') as csvfile:
    neo4jwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    
    headerValues = ['conceptId:ID', ':LABEL']
    neo4jwriter.writerow(headerValues)
    
    for row in query_result:
        rowValues = [str(row['x'].encode('utf-8')), 'ConceptScheme']
        #rowValues = ['' if x is None else str(x.encode('utf-8')) for x in rowValues]
        rowValues[0] = '`' + rowValues[0] + '`'
        neo4jwriter.writerow(rowValues)


# these are the relations we want to look for
# querying rdflib is very slow for some queries, helps to be as specific as possible
relations = ['skos:broader', 'skos:narrower', 'skos:narrowMatch', 'skos:broadMatch', 'skos:exactMatch', 'skos:relatedMatch']
filename = '/home/cbdavis/Desktop/neo4j_rels.csv'

# write header, will erase any previous values
with open(filename, 'wb') as csvfile:
    neo4jwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    
    headerValues = [':START_ID', ':END_ID', ':TYPE']
    neo4jwriter.writerow(headerValues)

for relation in relations:
    print relation
    
    # check that we're linking to something that is a skos:Concept
    # this avoids import errors later
    # what's not clear are entries like this: 
    # CN	CPA_2008	START	END
    # 85421134	261130	01/01/1995	31/12/1995
    # this appears to be an old CN code, it's not in the 2015 or 2016 documentation

    query_result = g.query(prefixes + """
        select ?s ?o where {
            ?s rdf:type skos:Concept . 
            ?s """ + relation + """ ?o . 
            ?o rdf:type skos:Concept . 
        } 
       """)
       
    with open(filename, 'a') as csvfile:
        neo4jwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        
        for row in query_result:
            s = str(row[0].encode('utf-8'))
            #p = str(row[1].encode('utf-8')).replace('http://www.w3.org/2004/02/skos/core#', 'skos:')
            p = relation.replace("skos:", "")
            o = str(row[1].encode('utf-8'))
            
            rowValues = [s, o, p]
            #rowValues = ['`' + x + '`' for x in rowValues]
            rowValues[0] = '`' + rowValues[0] + '`'
            rowValues[1] = '`' + rowValues[1] + '`'
    
            neo4jwriter.writerow(rowValues)

### skos:inScheme 

query_result = g.query(prefixes + """
    select ?x ?scheme where {
        ?x skos:inScheme ?scheme . 
        ?scheme rdf:type skos:ConceptScheme . 
    }
""")

p = "inScheme"

with open(filename, 'a') as csvfile:
    neo4jwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    
    for row in query_result:
        s = str(row['x'].encode('utf-8'))
        #p = str(row[1].encode('utf-8')).replace('http://www.w3.org/2004/02/skos/core#', 'skos:')
        
        o = str(row['scheme'].encode('utf-8'))
        
        rowValues = [s, o, p]
        #rowValues = ['`' + x + '`' for x in rowValues]
        rowValues[0] = '`' + rowValues[0] + '`'
        rowValues[1] = '`' + rowValues[1] + '`'

        neo4jwriter.writerow(rowValues)

# ./bin/neo4j-import --into /home/cbdavis/Desktop/neo4j --multiline-fields=true --nodes /home/cbdavis/Desktop/neo4j_nodes.csv --relationships /home/cbdavis/Desktop/neo4j_rels.csv
# ./bin/neo4j-import --into /home/cbdavis/Downloads/neo4j-community-3.0.3/data/databases/graph.db --multiline-fields=true --nodes /home/cbdavis/Desktop/neo4j_nodes.csv --relationships /home/cbdavis/Desktop/neo4j_rels.csv

# ./bin/neo4j-import --into /home/cbdavis/Downloads/neo4j-community-3.0.3/data/databases/graph.db --multiline-fields=true --nodes /home/cbdavis/Desktop/neo4j_skos_concepts.csv --nodes /home/cbdavis/Desktop/neo4j_skos_concept_schemes.csv  --relationships /home/cbdavis/Desktop/neo4j_rels.csv