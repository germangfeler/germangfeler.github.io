##-----------------------------------------------------
##
## DataViz II: Tortas y barras
## Autor: German A. Gonzalez
## Fecha: Nov-2018
## germangfeler.github.io/datascience/shape-of-you/
##
##-----------------------------------------------------

## Cargamos ggplot2
library(ggplot2)
library(dplyr)

starwars

humans <- filter(starwars, species=="Human")

g <- ggplot(humans, aes(species))
g + geom_bar() +  coord_flip() + theme_classic()


## Barplot
g <- ggplot(humans, aes(eye_color)) + 
     geom_bar(fill="steelblue") + theme_classic()
g
ggsave(filename="barplot1.png", width=5, height=4)

## Rotamos el gráfico     
g  +  coord_flip()
ggsave(filename="barplot2.png", width=5, height=4)


## Barplot con sexo
g <- ggplot(humans, aes(eye_color)) + 
     geom_bar(aes(fill=gender)) + theme_classic()
g
ggsave(filename="barplot3.png", width=5, height=4)

## Barplot con sexo dodge
g <- ggplot(humans, aes(eye_color)) + 
     geom_bar(aes(fill=gender), position = "dodge") + theme_classic()
g
ggsave(filename="barplot4.png", width=5, height=4)

