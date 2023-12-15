---
layout: single
title: "R: Old School vs tidyverse"
categories: datascience
tags:
  - tidyverse
  - R
  - Exploración
header:
  teaser: /assets/img/data-science/tidyverse.png
toc: true
toc_label: "Secciones"
excerpt: "Comparamos los dos universos"  
---

Hace algunos años este pibe de moñito vino a sacarnos de la modorra y cambiar la forma de programar en R.

![wickham](/assets/img/data-science/wickham.jpg)
<p><i>Hadley Wickham</i></p>

Hadley creó un ecosistema de paquetes, conocido como <strong>tidyverse</strong>, que permite manipular, explorar y visualizar datos.   

![wickham](/assets/thumbnails/tidyverse.png)

Estas cosas ya se podían hacer en R base, entonces ¿qué aportó el tidyverse? principalmente coherencia, algo en lo que R estaba escaso. Trabajar en un equipo pequeño permitió asegurar que todos los paquetes respetan la misma lógica y filosofía. Además se simplificaron algunas tareas básicas, poniendo énfasis en que sea más fácil de aprender y más productivo, requiriendo menos tiempo de programación.

No todo es color de rosa, el tidyverse tiene sus limitaciones. En especial cuando trabajamos con datos que no tienen formato de tabla. Por esta razón siempre van a convivir los dos sistema y está en cada analista de datos decidir cual es la mejor alternativa para su problema particular.

Hoy vamos a comparar como se realiza la misma tarea en R base (Old School) y tidyverse, usando nuevamente el dataset starwars.

```r
> library(tidyverse)
```

<h2>Selección de filas</h2>

Una de las operaciones que hacemos más a menudo cuando analizamos datos es seleccionar filas (usualmente, filas = observaciones). En este caso queremos trabajar solo con los personajes humanos de Star Wars. ¿Cómo hacemos eso en R base y en el tidyverse?

<strong>Old School</strong>

Lo vamos a hacer utilizando el operador de selección [ ] junto con el operador de comparación == 

```r
> humans <- starwars[starwars$species == "Human",]
```

<strong>tidyverse</strong>

Debemos utilizar la función <i>filter</i> junto con el operador de comparación ==.

```r
> humant <- filter(starwars, species == "Human")
```

El resultado es:
```r
A tibble: 35 x 13
   name         height  mass hair_color  skin_color eye_color birth_year gender
   <chr>         <int> <dbl> <chr>       <chr>      <chr>          <dbl> <chr> 
 1 Luke Skywal~    172    77 blond       fair       blue            19   male  
 2 Darth Vader     202   136 none        white      yellow          41.9 male  
 3 Leia Organa     150    49 brown       light      brown           19   female
 4 Owen Lars       178   120 brown, grey light      blue            52   male  
 5 Beru Whites~    165    75 brown       light      blue            47   female
 6 Biggs Darkl~    183    84 black       light      brown           24   male  
 7 Obi-Wan Ken~    182    77 auburn, wh~ fair       blue-gray       57   male  
 8 Anakin Skyw~    188    84 blond       fair       blue            41.9 male  
 9 Wilhuff Tar~    180    NA auburn, gr~ fair       blue            64   male  
10 Han Solo        180    80 brown       fair       brown           29   male  
... with 25 more rows, and 5 more variables: homeworld <chr>, species <chr>,
  films <list>, vehicles <list>, starships <list>
```
 
También podemos querer filtrar por dos criterios al mismo tiempo. En este caso buscamos a aquellos humanos que midan más de 1.85.

<strong>Old School</strong>

Similar al caso anterior pero ahora tenemos dos condiciones, que relacionaremos mediante el operador &. 

```r
> altos.s <- starwars[starwars$species == "Human" & 
                      starwars$height > 185,]
```

<strong>tidyverse</strong>

En el caso de filter, podemos agregar más condiciones simplemente separándolas con comas.

```r
> altos.t <- filter(starwars, species == "Human", 
                    starwars$height > 185)
```

El resultados en ambos casos es:

```r
  name           height  mass hair_color skin_color eye_color birth_year gender
  <chr>           <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> 
1 Darth Vader       202   136 none       white      yellow          41.9 male  
2 Anakin Skywal~    188    84 blond      fair       blue            41.9 male  
3 Qui-Gon Jinn      193    89 brown      fair       blue            92   male  
4 Mace Windu        188    84 none       dark       brown           72   male  
5 Dooku             193    80 white      fair       brown          102   male  
6 Bail Prestor ~    191    NA black      tan        brown           67   male  
7 Raymus Antill~    188    79 brown      light      brown           NA   male  
... with 5 more variables: homeworld <chr>, species <chr>, films <list>,
  vehicles <list>, starships <list>

```

<h2>Reordenar filas</h2>

El siguiente paso es ordenar los personajes según su altura y su peso.

<strong>Old School</strong>

Usamos la función <i>order</i> en conjunto con el operador de selección [ ].

```r
> altos.s[order(altos.s$height, altos.s$mass),]
```

<strong>tidyverse</strong>

Usamos la función <i>arrange</i>

```r
> arrange(altos.t, height, mass)
```

El resultado es:

```r
A tibble: 7 x 13
  name           height  mass hair_color skin_color eye_color birth_year gender
  <chr>           <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> 
1 Raymus Antill~    188    79 brown      light      brown           NA   male  
2 Anakin Skywal~    188    84 blond      fair       blue            41.9 male  
3 Mace Windu        188    84 none       dark       brown           72   male  
4 Bail Prestor ~    191    NA black      tan        brown           67   male  
5 Dooku             193    80 white      fair       brown          102   male  
6 Qui-Gon Jinn      193    89 brown      fair       blue            92   male  
7 Darth Vader       202   136 none       white      yellow          41.9 male  
... with 5 more variables: homeworld <chr>, species <chr>, films <list>,
   vehicles <list>, starships <list>
```

<h2>Seleccion de columnas</h2>

A veces tenemos muchas variables y queremos crear un nuevo dataset con una selección de las que más nos interesan. Tanto en R base como en el tidyverse hay más de una manera de hacer esto.

<strong>Old School</strong>

Forma 1: usando los nombres de columna

```r
> altos.s[,c("name", "height", "mass", "hair_color")]
```
Forma 2: usando indices

```r
> altos.s[,1:4]
```

<strong>tidyverse</strong>

Forma 1: nombrando explicitamente las columnas

```r
> select(starwars, name, height, mass, hair_color)
```

Forma 2: nombrando solo la primera y la última

```r
> select(starwars, name:hair_color)
```

El resultados en todos los casos es:

```r
   name               height  mass hair_color   
   <chr>               <int> <dbl> <chr>        
 1 Luke Skywalker        172    77 blond        
 2 C-3PO                 167    75 NA           
 3 R2-D2                  96    32 NA           
 4 Darth Vader           202   136 none         
 5 Leia Organa           150    49 brown        
 6 Owen Lars             178   120 brown, grey  
 7 Beru Whitesun lars    165    75 brown        
 8 R5-D4                  97    32 NA           
 9 Biggs Darklighter     183    84 black        
10 Obi-Wan Kenobi        182    77 auburn, white
# ... with 77 more rows
```

Algo interesante de <i>select</i> es que tiene un montón de funciones auxiliares piolas como:
* starts_with("abc"), busca nombres de columna que empiecen con “abc”.
* ends_with("xyz"), busca nombres de columna que terminen con “xyz”.
* contains("ijk"), busca nombres de columna que contengan la cadena “ijk”.
* matches("(.)\\1"), selecciona columnas en base a expresiones regulares
* num_range("x", 1:3), selecciona x1, x2 y x3.

<h2>Agregar columnas</h2>
Queremos crear una nueva columna, llamada bmi, con el índice de masa corporal de cada personaje. El bmi se calcula como peso / altura^2.

<strong>Old School</strong>

El operador $ permite acceder al contenido de una columna. En este caso, como estamos accediendo a una columna que aún no existe (bmi), de hecho la estamos creando.

```r
> altos.s$bmi <-  altos.s$mass / (altos.s$height/100)^2
```

<strong>tidyverse</strong>

La función <i>mutate</i> permite crear nuevas variables que sean transformaciones de otras.

```r
> altos.t <- mutate(altos.t,
     bmi = mass / (height/100)^2)
```

El resultado es:

```r
  name                height  mass   bmi
  <chr>                <int> <dbl> <dbl>
1 Darth Vader            202   136  33.3
2 Anakin Skywalker       188    84  23.8
3 Qui-Gon Jinn           193    89  23.9
4 Mace Windu             188    84  23.8
5 Dooku                  193    80  21.5
6 Bail Prestor Organa    191    NA  NA  
7 Raymus Antilles        188    79  22.4
```

<h2>Combinando operaciones</h2>

Una de las características más relevantes del tidyverse es que permite combinar operaciones usando el pipe (%>%). De esta manera nos ahorramos el paso de crear objetos con resultados intermedios.

```r
> altos.t <- starwars %>% 
             filter(species == "Human", starwars$height > 185) %>%
             select(name:hair_color) %>%
             mutate(bmi = mass / (height/100)^2)
> altos.t
A tibble: 7 x 5
  name                height  mass hair_color   bmi
  <chr>                <int> <dbl> <chr>      <dbl>
1 Darth Vader            202   136 none        33.3
2 Anakin Skywalker       188    84 blond       23.8
3 Qui-Gon Jinn           193    89 brown       23.9
4 Mace Windu             188    84 none        23.8
5 Dooku                  193    80 white       21.5
6 Bail Prestor Organa    191    NA black       NA  
7 Raymus Antilles        188    79 brown       22.4
```

¿Y ustedes que usan en el día a día? ¿#teamBaseR o #teamTidyverse?

Nos vemos la próxima y si les gustó el post recuerden comentar / compartir / megustear.

Desde <a href="/assets/scripts/oldvstidy.R">aquí</a> pueden descargar el script completo para R.
