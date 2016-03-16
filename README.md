# what-links-to-what

## what?
This is an ongoing effort to map the interlinkages between various industrial & product classification systems along with other databases of interest (pollution, LCA, etc.).

## how?
The data is represented using the [graphviz dot format](http://www.graphviz.org/content/dot-language) in the file `WhatLinksToWhat.dot.m4`.  We additionally use [m4](http://www.gnu.org/software/m4/m4.html) to help replace variable names with colors representing the different types fo classifications.

The image below is rendered with [graphviz](http://www.graphviz.org) using:

```
bash ./WhatLinksToWhat.sh
```

## links

<img src=https://raw.githubusercontent.com/isdata-org/what-links-to-what/master/WhatLinksToWhat.png>
