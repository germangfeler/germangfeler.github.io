---
layout: single
title: "Old School vs Tidyverse"
permalink: /draft2/
header:
  teaser: /assets/thumbnails/ciencia_datos.png
excerpt: "De que lados estás amigo"
---

Este es un post para userRs viejos que están empezando la transición de R base al Tidyverse. O para aquellos que recién empiezan con R y no están seguros de cual es la mejor forma de aprender el lenguaje. Veamos como se hacen las operaciones básicas en cada caso y luego pueden elegir el que quieran.

Vamos a usar nuevamente el dataset starwars que viene con el tidyverse.

```r
> library(tidyverse)
```

<h2>Selección de filas</h2>

Una de las operaciones que hacemos más a menudo cuando analizamos datos es seleccionar filas (usualmente, filas = observaciones). En este caso queremos trabajar solo con los personajes humanos de Star Wars. ¿Cómo hacemos eso en R base y en el Tidyverse?

<strong>Old School</strong>
```r
> humans <- starwars[starwars$species=="Human",]
> humans

A tibble: 40 x 13
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
... with 30 more rows, and 5 more variables: homeworld <chr>, species <chr>,
  films <list>, vehicles <list>, starships <list>
```
  
<strong>Tidyverse</strong>

```r
> humant <- filter(starwars, species=="Human")
> humant

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

Ahora queremos filtrar por dos criterios al mismo tiempo. No solo necesitamos que sean humanos sino también que midan más de 1.85.

<strong>Old School</strong>
```r
> altos.s <- starwars[starwars$species == "Human" & starwars$height > 185,]
> altos.s

A tibble: 12 x 13
   name          height  mass hair_color skin_color eye_color birth_year gender
   <chr>          <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> 
 1 Darth Vader      202   136 none       white      yellow          41.9 male  
 2 Anakin Skywa~    188    84 blond      fair       blue            41.9 male  
 3 NA                NA    NA NA         NA         NA              NA   NA    
 4 Qui-Gon Jinn     193    89 brown      fair       blue            92   male  
 5 Mace Windu       188    84 none       dark       brown           72   male  
 6 Dooku            193    80 white      fair       brown          102   male  
 7 Bail Prestor~    191    NA black      tan        brown           67   male  
 8 Raymus Antil~    188    79 brown      light      brown           NA   male  
 9 NA                NA    NA NA         NA         NA              NA   NA    
10 NA                NA    NA NA         NA         NA              NA   NA    
11 NA                NA    NA NA         NA         NA              NA   NA    
12 NA                NA    NA NA         NA         NA              NA   NA    
... with 5 more variables: homeworld <chr>, species <chr>, films <list>,
  vehicles <list>, starships <list>
```

<strong>Tidyverse</strong>
```r
> altos.t <- filter(starwars, species=="Human", starwars$height > 185)
> altos.t

A tibble: 7 x 13
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

El siguiente paso sobre nuestros datos filtrados es ordenarlos según su altura y su peso.

<strong>Old School</strong>
```r
> altos.s[order(altos.s$height, altos.s$mass),]
A tibble: 12 x 13
   name          height  mass hair_color skin_color eye_color birth_year gender
   <chr>          <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> 
1 Raymus Antil~    188    79 brown      light      brown           NA   male  
2 Anakin Skywa~    188    84 blond      fair       blue            41.9 male  
3 Mace Windu       188    84 none       dark       brown           72   male  
4 Bail Prestor~    191    NA black      tan        brown           67   male  
5 Dooku            193    80 white      fair       brown          102   male  
6 Qui-Gon Jinn     193    89 brown      fair       blue            92   male  
7 Darth Vader      202   136 none       white      yellow          41.9 male  
```

<strong>Tidyverse</strong>
```r
> arrange(altos.t, height, mass)
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

A veces tenemos muchas variables y queremos crear un nuevo dataset con una selección de las que más nos interesan. Tanto en R base como en el Tidyverse hay más de una manera de hacer esto:

<strong>Old School</strong>
Forma 1: usando los nombres de columna

```r
> altos.s[,c("name", "height", "mass", "hair_color")]
A tibble: 12 x 4
   name                height  mass hair_color
   <chr>                <int> <dbl> <chr>     
1 Darth Vader            202   136 none      
2 Anakin Skywalker       188    84 blond     
3 NA                      NA    NA NA        
4 Qui-Gon Jinn           193    89 brown     
5 Mace Windu             188    84 none      
6 Dooku                  193    80 white     
7 Bail Prestor Organa    191    NA black     
8 Raymus Antilles        188    79 brown     
```
Forma 2: usando indices

```r
> altos.s[,1:4]
  name                height  mass hair_color
   <chr>                <int> <dbl> <chr>     
1 Darth Vader            202   136 none      
2 Anakin Skywalker       188    84 blond     
3 NA                      NA    NA NA        
4 Qui-Gon Jinn           193    89 brown     
5 Mace Windu             188    84 none      
6 Dooku                  193    80 white     
7 Bail Prestor Organa    191    NA black     
8 Raymus Antilles        188    79 brown     
```

<strong>Tidyverse</strong>
Forma 1: nombrando explicitamente las columnas
```r
> select(starwars, name, height, mass, hair_color)
A tibble: 87 x 4
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
... with 77 more rows
```

Forma 2: nombrando solo la primera y la última
```r
> select(starwars, name:hair_color)
A tibble: 87 x 4
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

Además, <i>select</i> tiene un montón de funciones auxiliares piolas como:
* starts_with("abc"), busca nombres de columna que empiecen con “abc”.
* ends_with("xyz"), busca nombres de columna que terminen con “xyz”.
* contains("ijk"), busca nombres de columna que contengan la cadena “ijk”.
* matches("(.)\\1"), selecciona columnas en base a expresiones regulares
* num_range("x", 1:3), selecciona x1, x2 y x3.

<h2>Agregar columnas</h2>
Queremos crear una nueva columna, llamada bmi, con el índice de masa corporal de cada personaje. El bmi se calcula como peso / altura^2.

<strong>Old School</strong>
```r
> altos.s$bmi <-  altos.s$mass / (altos.s$height/100)^2
> altos.s[,c("name", "height", "mass", "bmi"),]
A tibble: 12 x 4
   name                height  mass   bmi
   <chr>                <int> <dbl> <dbl>
1 Darth Vader            202   136  33.3
2 Anakin Skywalker       188    84  23.8
3 NA                      NA    NA  NA  
4 Qui-Gon Jinn           193    89  23.9
5 Mace Windu             188    84  23.8
6 Dooku                  193    80  21.5
7 Bail Prestor Organa    191    NA  NA  
8 Raymus Antilles        188    79  22.4
```

<strong>Tidyverse</strong>
```r
> altos.t <- mutate(altos.t,
     bmi = mass / (height/100)^2)
> select(altos.t, name, height, mass, bmi)
A tibble: 7 x 4
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

Una de las cosas más interesantes que permite el tidyverse es combinar operaciones usando el pipe (%>%). De esta manera nos ahorramos el paso de crear objetos con resultados intermedios.

```r
> altos.t <- starwars %>% 
             filter(species=="Human", starwars$height > 185) %>%
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

Nos vemos la próxima y si les gustó el post recuerden comentar / compartir / megustear.

Desde <a href="/assets/scripts/oldvstidy.R">aquí</a> pueden descargar el script completo para R.
