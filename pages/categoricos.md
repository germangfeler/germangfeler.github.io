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
toc: true
toc_label: "Secciones"
excerpt: "Como visualizar y explorar datos categóricos"  
---

<i>Previously on this blog...</i> analizamos algunas alternativas para <a href="https://germangfeler.github.io/datascience/shape-of-you/">visualizar datos continuos</a>. Hoy le toca el turno a los datos categóricos, es decir, variables que pueden tomar una cantidad limitada de valores. Ejemplos de esto pueden ser: el grupo sanguíneo (A, B, AB o 0), el barrio en que uno vive (Alberdi, Güemes, Nueva Córdoba, entre otros) o la religión que profesa (cristiano, musulmán, judío, entre otros).

En esta oportunidad vamos a trabajar con el dataset de Star Wars que viene en el paquete dplyr. Para simplificar un poco usaremos solo a los personajes humanos.

```r
> library(ggplot2)
> library(dplyr)

> starwars
# A tibble: 87 x 13
   name         height  mass hair_color  skin_color eye_color birth_year gender
   <chr>         <int> <dbl> <chr>       <chr>      <chr>          <dbl> <chr> 
 1 Luke Skywal~    172    77 blond       fair       blue            19   male  
 2 C-3PO           167    75 NA          gold       yellow         112   NA    
 3 R2-D2            96    32 NA          white, bl~ red             33   NA    
 4 Darth Vader     202   136 none        white      yellow          41.9 male  
 5 Leia Organa     150    49 brown       light      brown           19   female
 6 Owen Lars       178   120 brown, grey light      blue            52   male  
 7 Beru Whites~    165    75 brown       light      blue            47   female
 8 R5-D4            97    32 NA          white, red red             NA   NA    
 9 Biggs Darkl~    183    84 black       light      brown           24   male  
10 Obi-Wan Ken~    182    77 auburn, wh~ fair       blue-gray       57   male  
# ... with 77 more rows, and 5 more variables: homeworld <chr>, species <chr>,
#   films <list>, vehicles <list>, starships <list>

> humans <- filter(starwars, species=="Human")

```

<h3>Gráfico de barras</h3>

Construir un gráfico en ggplot2 es un proceso que sucede en etapas. Primero definimos el dataset y las variables que vamos a utilizar y luego le vamos sumando elementos como el tipo de gráfico (el <i>geom</i>), el aspecto general del gráfico (el <i>theme</i>), los nombres de los ejes y otros detalles que vamos a ir viendo.

El gráfico de barras (o barplot) básico se hace de la siguiente manera:

```r
> ## Barplot
> g <- ggplot(humans, aes(eye_color)) + 
     geom_bar(fill="steelblue") + theme_classic()
> g
```

{:.center}
![bar1](/assets/img/dataviz2/barplot1.png)

Si nos gusta más que las barras sean horizontales podemos rotarlo agregando un nuevo elemento:

```r
> g  +  coord_flip() 
```

{:.center}
![bar2](/assets/img/dataviz2/barplot2.png)

