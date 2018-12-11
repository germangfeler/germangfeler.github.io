##-----------------------------------------------------
##
## Old School vs Tidyverse
## Autor: German A. Gonzalez
## Fecha: Dic-2018
## germangfeler.github.io/datascience/old-school-vs-tidyverse/
##
##-----------------------------------------------------

## Cargamos ggplot2 y dplyr
library(tidyverse)

## Dataset
starwars
starwars.df <- as.data.frame(starwars)

##-------- Seleccion de filas ----------
## Nos quedamos con los personajes femeninos

## old school
humans <- starwars.df[starwars.df$species=="Human",]

## Tidyverse
humant <- filter(starwars, species=="Human")

  
## Filtrado por dos criterios  

## old school
fems <- starwars.df[starwars.df$species=="Human" & starwars.df$gender=="female",]

## Tidyverse
femt <- filter(starwars, species=="Human", gender=="female")



##-------- Seleccion de columnas ----------
## Nos quedamos con los personajes femeninos

## old school
humans <- starwars.df[starwars.df$species=="Human",]

## Tidyverse
humant <- filter(starwars, species=="Human")
