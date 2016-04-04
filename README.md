# what-links-to-what

## What?
This is an ongoing effort to map the interlinkages between various industrial & product classification systems along with other databases of interest (facility pollution, LCA, etc.).

## Visualized Links

<img src=https://raw.githubusercontent.com/isdata-org/what-links-to-what/master/WhatLinksToWhat.png>

## Data Sources
* [RAMON - Reference And Management Of Nomenclatures: Index of Correspondence Tables](http://ec.europa.eu/eurostat/ramon/relations/index.cfm?TargetUrl=LST_REL)
* [United National Statistics Division - Classifications Registry](http://unstats.un.org/unsd/cr/registry/regot.asp?Lg=1)

### Classifications
#### Industrial
* ANZSIC - [Australian and New Zealand Standard Industrial Classification]()
* ISIC - International Standard Industrial Classification of All Economic Activities
* JSIC - Japanese Standard Industrial Classification 
* NACE - [Statistical Classification of Economic Activities in the European Community (nomenclature statistique des activités économiques dans la Communauté européenne)](https://en.wikipedia.org/wiki/Statistical_Classification_of_Economic_Activities_in_the_European_Community)
* NAICS - [North American Industry Classification System](https://en.wikipedia.org/wiki/North_American_Industry_Classification_System)
* SIC - [Standard Industrial Classification](https://en.wikipedia.org/wiki/Standard_Industrial_Classification)
 
#### Product
* BEC - Broad Economic Categories
* BTN - Brussels Tariff Nomenclature
* CCT - Common Customs Tariff
* CN - [Combined Nomenclature](http://ec.europa.eu/taxation_customs/customs/customs_duties/tariff_aspects/combined_nomenclature/index_en.htm)
* CPA - Classification of Products by Activity
* HS - Harmonized System
* NAPCS - North American Product Classification System
* NIMEXE - Nomenclature of Goods for the External Trade Statistics of the Community and Statistics of Trade between Member States
* NST/R - Standard Goods Classification for Transport Statistics/Revised 
* PRODCOM - PRODuction COMmunautaire
* SITC - Standard International Trade Classification


## How?
The data is represented using the [graphviz dot format](http://www.graphviz.org/content/dot-language) in the file `WhatLinksToWhat.dot.m4`.  We additionally use [m4](http://www.gnu.org/software/m4/m4.html) to help replace variable names with colors representing the different types of classifications.

The image shown on this page is rendered with [graphviz](http://www.graphviz.org) using:

```
bash ./WhatLinksToWhat.sh
```

This script also generates the `WhatLinksToWhat.dot` file, and you can use this to then render to other formats like svg.
