---
layout: single
title: "Old School vs Tidyverse"
permalink: /draft2/
header:
  teaser: /assets/thumbnails/ciencia_datos.png
excerpt: "De que lados estás amigo"
---

<h2>Selección de filas</h2>

```r
> ## Cargamos los paquetes
> library(tidyverse)

## Old school
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

## Tidyverse
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

Filtramos por dos criterios

```r
## old school
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

## Tidyverse
altos.t <- filter(starwars, species=="Human", starwars$height > 185)
altos.t

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
