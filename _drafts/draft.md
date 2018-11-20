---
layout: single
title: "Draft"
categories: datascience
tags:
  - DataViz
  - Visualización
  - Exploración
  - ggplot2
  - R
header:
  teaser: /assets/img/dataviz/violin.png
excerpt: "Conociendo la forma de mis datos"  
---

Hablando de palabras nuevas para nombrar cosas viejas, hoy empezamos una serie de artículos sobre <i>DataViz</i>. O como decimos en criollo, visualización de datos. Un conjunto de técnicas que nos van a permitir representar gráficamente información, con el objeto de entenderla mejor o de comunicar eficientemente resultados.

Un error frecuente en analistas de datos <i>newbies</i> es querer ir directo a los bifes sin juego previo. Si antes de modelar datos paramos la pelota para estudiar su naturaleza y su forma nos ahorraremos unos cuantos dolores de cabeza. Ahí es donde las herramientas que veremos hoy entran en juego.

Pero primero lo primero, necesitamos un <i>dataset</i> a modo de ejemplo para trabajar. En este caso elegí <i>InsectSprays</i> una tabla con la cantidad de insectos encontrados en parcelas agrícolas tratadas con diferentes sprays de insecticidas. Con las funciones <i>head</i> y <i>tail</i> podemos ver las primeras y últimas filas de la tabla.


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
