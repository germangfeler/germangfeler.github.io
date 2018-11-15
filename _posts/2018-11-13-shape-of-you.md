---
layout: single
title: "DataViz I: Shape of You"
categories: datascience
header:
  teaser: /assets/img/dataviz/violin.png
excerpt: "Conociendo la forma de mis datos"  
---

Hablando de palabras nuevas para nombrar cosas viejas, hoy empezamos una serie de artículos sobre <i>DataViz</i>. O como decimos en criollo, visualización de datos. Es decir un conjunto de técnicas que nos van a permitir representar gráficamente información, con el objeto de entenderla mejor o de comunicar eficientemente resultados.

Un error frecuente en analistas de datos <i>newbies</i> es querer ir directo a los bifes sin juego previo. Aunque suene tentador, hay que evitar modelar una variable sin estudiar antes su naturaleza y su forma. Ahí es donde las herramientas que veremos hoy entran en juego.

Pero primero lo primero, necesitamos un <i>dataset</i> a modo de ejemplo para trabajar. Por eso elegí <i>InsectSprays</i> una tabla con la cantidad de insectos encontrados en parcelas agrícolas tratadas con diferentes sprays de insecticidas.


```{r}
> head(InsectSprays)
  count spray
1    10     A
2     7     A
3    20     A
4    14     A
5    14     A
6    12     A

```

Podemos

```{r}
> library(ggplot2)

```
