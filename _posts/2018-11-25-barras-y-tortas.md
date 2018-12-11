---
layout: single
title: "DataViz II: barras y tortas"
categories: datascience
tags:
  - DataViz
  - Visualización
  - Exploración
  - ggplot2
  - R
header:
  teaser: /assets/thumbnails/treemap.png
toc: true
toc_label: "Secciones"
excerpt: "Visualizando datos categóricos"  
---

<i>Previously on this blog...</i> analizamos algunas alternativas para <a href="https://germangfeler.github.io/datascience/shape-of-you/">visualizar datos continuos</a>. Hoy le toca el turno a los datos categóricos, es decir, variables que pueden tomar una cantidad limitada de valores. Ejemplos de esto pueden ser: el grupo sanguíneo (A, B, AB o 0), el barrio en que uno vive (Alberdi, Güemes, Nueva Córdoba, entre otros) o la religión que profesa (cristiano, musulmán, judío, entre otros).

Después de bucear la web en busca de un dataset interesante para mostrar estas técnicas llegué a éste que tiene información sobre los personajes de la saga Star Wars (<i>alerta nerd</i>). Para simplificar un poco usaremos solo los personajes humanos.

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

En particular nos va a interesar explorar el color de ojos de los personajes.


<h2>Gráfico de barras para una variable</h2>

Un gráfico en ggplot2 es como una cebolla, está formado por capas, que iremos agregando con el operador "+". Primero definimos el dataset y las variables que vamos a utilizar y luego le vamos sumando elementos como el tipo de gráfico (el <i>geom</i>), el aspecto general del gráfico (el <i>theme</i>), los nombres de los ejes (<i>xlab</i>, <i>ylab</i>) y otros detalles que vamos a ir viendo.

El gráfico de barras (o barplot) básico se hace de la siguiente manera:

```r
> ## Barplot
> g <- ggplot(humans, aes(eye_color)) + 
     geom_bar(fill="steelblue") + theme_classic()
> g
```

Como le estamos pasando una columna con datos categóricos a ggplot2 y pidiendole un <i>geom_bar</i> sabe que debe generar un gráfico de barras contando la frecuencia de cada categoría.

{:.center}
![bar1](/assets/img/dataviz2/barplot1.png)

Si nos gusta más que las barras sean horizontales podemos rotarlo agregando un nuevo elemento:

```r
> g  +  coord_flip() 
```

{:.center}
![bar2](/assets/img/dataviz2/barplot2.png)

Si lo que nos interesa graficar es el porcentaje, en lugar de la frecuencia absoluta, primero vamos a tener que calcular ese dato. En este caso lo hice utlizando las funciones del paquete dplyr que aplican transformaciones en cascada sobre los datos: contar cuantos elementos hay en cada grupo (color de ojos, en este caso) y luego calcular el porcentaje. Luego hacemos el gráfico de barras de forma similar a lo que aplicamos antes pero con el argumento <i>stat="identity"</i> para indicar que los valores a graficar ya están calculados y no hay que hacer ningún calculo adicional.

```r
> ## Convertimos a porcentaje
> humans_pct <- humans %>% 
                group_by(eye_color) %>% 
                count() %>% 
                ungroup() %>% 
                mutate(percentage=`n`/sum(`n`) * 100) 

> ## Barplot  
> ggplot(humans_pct, aes(x=eye_color, y=percentage)) + 
     geom_bar(stat="identity", fill="steelblue") + 
     theme_classic() + coord_flip()
```

{:.center}
![bar2pct](/assets/img/dataviz2/barplot2_pct.png)

<strong>WARNING:</strong> evitar los gráficos de barras en 3D, agregar una falsa tercera dimensión solo hace más confusa la interpretación sin agregar información. Como dicen Good y Hardin "no hagas gráficos que muestren más dimensiones que las que existen en los datos".

{:.center}
![bar3D](/assets/img/dataviz2/barplot3D.png)
<br>
<i>Gráfico de barras en 3D tomado de Common Errors in Statistics de Good & Hardin.</i>

<h2>Gráfico de barras para dos variables</h2>

Muchas veces queremos visualizar dos factores a la vez. Por ejemplo, si queremos saber cuantas de las personas con ojos marrones son hombres y cuantas mujeres. Para hacer esto vamos a pasarle el dato del género (columna gender) al argumento <i>fill</i>, de manera que utilice diferentes colores para cada uno.

```r
> ggplot(humans, aes(eye_color)) + 
     geom_bar(aes(fill=gender)) + theme_classic()
```

{:.center}
![bar3](/assets/img/dataviz2/barplot3.png)

Ahora para cada color de ojos la barra aparece particionada entre sexos.

Si las barras apiladas no son lo nuestro le podemos pedir a ggplot que ponga una al lado de la otra usando el argumento <i>position="dodge"</i>.

```r
> ggplot(humans, aes(eye_color)) + 
     geom_bar(aes(fill=gender), position = "dodge") + 
     theme_classic()
```

{:.center}
![bar4](/assets/img/dataviz2/barplot4.png)


<h2>Cleveland dot plot</h2>

Los gráficos de barra siguen siendo muy usados hasta el dia de hoy pero tienen una pequeña contra: usan demasiada "tinta" para contar su historia. Por eso en los '80 Cleveland y McGill propusieron otra técnica de visualización más simple que solo usa líneas y puntos:

```r
> ggdotchart(humans_pct, x = "eye_color", y = "n",
           sorting = "descending", rotate = TRUE, 
           dot.size = 6, ggtheme = theme_pubr()) + 
           theme_cleveland()
```

{:.center}
![cleve](/assets/img/dataviz2/cleveland.png)

En algunas ocasiones se utiliza una versión ligeramente diferente que se conoce como Lollipop. Como podemos imaginar, recibe su nombre por el parecido que tiene con un chupetín.

{:.center}
![chupetin](/assets/img/dataviz2/chupetin.jpeg)
<p class="center"><i>Chupetín</i></p>

```r
> ggdotchart(humans_pct, x = "eye_color", y = "n",
           sorting = "descending", add = "segments", 
           rotate = TRUE, dot.size = 6,
           label = round(humans_pct$n), 
           font.label = list(color = "white", 
                        size = 9, vjust = 0.5),
           ggtheme = theme_pubr())
```

{:.center}
![lolli](/assets/img/dataviz2/Lollipop.png)

Otra característica interesante de estos gráficos es que son muy buenos para mostrar cambios en dos momentos de tiempo. Pero eso quedará para otra oportunidad.

<h2>Treemap</h2>

Una de las visualizaciones de moda (aunque existe desde hace décadas) definitivamente son los Treemaps. Se trata de graficar los datos con rectángulos de tamaño proporcional al valor de alguna variable.

```r
> library("treemapify")
> library("glue")

> ## Creamos la etiqueta con el porcentaje y la categoria
> lab <- humans_pct %>%
           glue_data('{round(percentage,1)}% \n{eye_color}')

> ggplot(humans_pct, aes(area = percentage, fill = eye_color,
        label = lab)) + geom_treemap() + 
        theme(legend.position="none") +
        geom_treemap_text(fontface = "italic", 
             colour = "white", place = "topleft",
             grow = TRUE) +
        scale_fill_manual(values = c("dodgerblue3", "cadetblue4", 
                "chocolate4", "black", "burlywood4", "gold2"))                  
```

{:.center}
![treemap](/assets/img/dataviz2/treemap.png)

La belleza de este gráfico es algo que no se puede negar. Como punto en contra está el hecho de que si tenemos muchas categorías y/o algunas muy pequeñas será difícil visualizarlas adecuadamente.

<h2>Cosas a evitar: gráfico de torta</h2>

¿Cómo se hace un gráfico de torta (o pie chart) en ggplot2? Aunque nos llame la atención no es con un nuevo geom sino que se trata de una transformación sobre el <i>geom_bar</i> (convertirlo a coordenadas polares).

```r
> ggplot(humans_pct, aes(x=1, y=percentage, fill=eye_color)) +
        geom_bar(stat="identity") +
        geom_text(aes(label = paste0(round(percentage,1),"%")), 
                  position = position_stack(vjust = 0.5)) +
        coord_polar(theta = "y") + 
        theme_void()
```

{:.center}
![pie](/assets/img/dataviz2/piechart.png)


Ahora una trivia con opciones: ¿Cuándo es buena idea usar gráficos de torta?
1. Nunca
2. Jamás
3. Ni en un millón de años

<strong>WARNING:</strong> Siempre que sea posible manténganse lejos de los gráficos de torta. Las dos principales razones son: 1) el ojo humano no es muy bueno estimando áreas 2) es díficil comparar "porciones" de la torta entre sí y entre diferentes gráficos. El gráfico de barras puede mostrar la misma información de una forma más sencilla de comparar para nuestros ojos.

<h2>Cosas a evitar: gráfico de líneas</h2>

¿Y que tal si unimos todos los puntos con una línea así?

{:.center}
![line](/assets/img/dataviz2/linechart.png)

No se ve mal pero ¿está bien usarlo? preguntémosle a Alberto:

{:.center}
![korn](/assets/img/dataviz2/kornblihtt.jpeg)

El problema con este gráfico es que al agregarle una línea uniendo los puntos da una falsa idea de relación lineal entre las categorías. Este tipo de gráficos es útil, por ejemplo, cuando se analizan tendencias y en el eje X tenemos el tiempo pero en este caso no está bien usarlo. 

Así terminamos este breve <i>Dos and Don'ts</i> de la visualización de datos categóricos. Nos vemos la próxima y si les gustó el post recuerden comentar / compartir / megustear.

Desde <a href="/assets/scripts/barrasytortas.R">aquí</a> pueden descargar el script completo para R.
