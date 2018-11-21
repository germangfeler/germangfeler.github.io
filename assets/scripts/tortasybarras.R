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


g <- ggplot(starwars, aes(species))
g + geom_bar() +  coord_flip() + theme_classic()

starwars <- starwars[starwars$species=="Human",]
starwars <- starwars[!is.na(starwars$name),]

## Barplot
g <- ggplot(starwars, aes(eye_color))
g <- g + geom_bar() +  coord_flip() + theme_classic()
g + geom_text(aes(label=len), vjust=1.6, color="white", size=3.5)

## Table
eyecolor <- as.data.frame(table(starwars$eye_color))
colnames(eyecolor) <- c("eye_color", "n")

## Barplot
g <- ggplot(eyecolor, aes(x=reorder(eye_color, n), y=n)) + xlab("eye color")
g <- g + geom_bar(stat="identity", fill="steelblue") +  coord_flip() + theme_classic()
g + geom_text(aes(label=n), vjust=-0.3, hjust=-0.3, size=6)

## Table
eh <- as.data.frame(table(starwars$eye_color, starwars$hair_color))
colnames(eh) <- c("eye_color", "n")

