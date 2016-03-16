#!/bin/bash
m4 WhatLinksToWhat.dot.m4 > WhatLinksToWhat.dot
dot -Tpng WhatLinksToWhat.dot -o WhatLinksToWhat.png
