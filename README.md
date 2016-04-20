# what-links-to-what

## What?
This is an effort to map the interlinkages between various industrial & product classification systems along with other databases of interest (facility pollution, LCA, etc.).

## Visualized Links
This is a rough map of all the classification and data sets that we are aware of:
<img src=https://raw.githubusercontent.com/isdata-org/what-links-to-what/master/WhatLinksToWhat.png>

In [the CodeLinkR folder](./CodeLinkR) we are working on software that can read the classifications and their concordances.  The matrices below shows the current status of these efforts.  The metadata used is stored in [classifications.yaml](./CodeLinkR/inst/classifications.yaml) and [concordances.yaml](./CodeLinkR/inst/concordances.yaml).

Which classification codes have been linked:

<img src=https://raw.githubusercontent.com/isdata-org/what-links-to-what/master/images/AdjMatrixSimplified-1.png width=400>

Which specific versions of the classification codes have been linked:

<img src=https://raw.githubusercontent.com/isdata-org/what-links-to-what/master/images/AdjMatrix-1.png width=600>

## Data Sources
* [RAMON - Reference And Management Of Nomenclatures: Index of Correspondence Tables](http://ec.europa.eu/eurostat/ramon/relations/index.cfm?TargetUrl=LST_REL)
* [RAMON - Reference And Management Of Nomenclatures: Metadata](http://ec.europa.eu/eurostat/ramon/index.cfm?TargetUrl=DSP_PUB_WELC)
* [United National Statistics Division - Classifications Registry](http://unstats.un.org/unsd/cr/registry/regot.asp?Lg=1)
* [World Bank Product Concordances](http://wits.worldbank.org/product_concordance.html)

### Classifications
#### Industrial
* ANZSIC - [Australian and New Zealand Standard Industrial Classification]()
* ISIC - [International Standard Industrial Classification of All Economic Activities](http://unstats.un.org/unsd/cr/registry/regcst.asp?Cl=27)
* JSIC - Japanese Standard Industrial Classification 
* NACE - [Statistical Classification of Economic Activities in the European Community (nomenclature statistique des activités économiques dans la Communauté européenne)](https://en.wikipedia.org/wiki/Statistical_Classification_of_Economic_Activities_in_the_European_Community)
* NAICS - [North American Industry Classification System](https://en.wikipedia.org/wiki/North_American_Industry_Classification_System)
* SIC - [Standard Industrial Classification](https://en.wikipedia.org/wiki/Standard_Industrial_Classification)
 
#### Product
* BEC - Broad Economic Categories
* BTN - Brussels Tariff Nomenclature
* CCT - Common Customs Tariff
* CN - [Combined Nomenclature](http://ec.europa.eu/taxation_customs/customs/customs_duties/tariff_aspects/combined_nomenclature/index_en.htm)
* CPA - [Statistical Classification of Products by Activity](http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=LST_NOM_DTL&StrNom=CPA_2_1&StrLanguageCode=EN&IntPcKey=&StrLayoutCode=HIERARCHIC)
* CPC - [Central Product Classification](http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_DFLT_LAYOUT&StrNom=CPC_2_1&StrLanguageCode=EN)
* HS - Harmonized System
* NAPCS - North American Product Classification System
* NHM - [Harmonised Commodity Code 'Nomenclature harmonisée des marchandises'](http://ec.europa.eu/eurostat/ramon/other_documents/nhm/index.cfm?TargetUrl=DSP_NHM)
* NIMEXE - [Nomenclature of Goods for the External Trade Statistics of the Community and Statistics of Trade between Member States](http://ec.europa.eu/eurostat/ramon/other_documents/ancestors/nimexe/index.cfm?TargetUrl=DSP_NIMEXE)
* NST/R - [Standard Goods Classification for Transport Statistics/Revised](http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=LST_NOM_DTL&StrNom=NSTR_1967&StrLanguageCode=EN&IntPcKey=&StrLayoutCode=HIERARCHIC)
* PRODCOM - PRODuction COMmunautaire
* SITC - Standard International Trade Classification


## How?
The data is represented using the [graphviz dot format](http://www.graphviz.org/content/dot-language) in the file `WhatLinksToWhat.dot.m4`.  We additionally use [m4](http://www.gnu.org/software/m4/m4.html) to help replace variable names with colors representing the different types of classifications.

The image shown on this page is rendered with [graphviz](http://www.graphviz.org) using:

```
bash ./WhatLinksToWhat.sh
```

This script also generates the `WhatLinksToWhat.dot` file, and you can use this to then render to other formats like svg.
