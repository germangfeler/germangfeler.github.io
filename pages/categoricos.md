---
layout: single
title: "DataViz II: barras y tortas"
categories: datascience
permalink: /draft/
tags:
  - DataViz
  - Visualización
  - Exploración
  - ggplot2
  - R
header:
  teaser: /assets/img/dataviz/violin.png
excerpt: "Como visualizar y explorar datos categóricos"  
---

<i>Previously on this blog...</i> analizamos algunas alternativas para <a href="https://germangfeler.github.io/datascience/shape-of-you/">visualizar datos continuos</a>. Hoy le toca el turno a los datos categóricos.



```r
> head(InsectSprays,3)
  count spray
1    10     A
2     7     A
3    20     A
> tail(InsectSprays,3)
   count spray
70    26     F
71    24     F
72    13     F
```

{:.center}
![density](/assets/img/dataviz/density.png)

