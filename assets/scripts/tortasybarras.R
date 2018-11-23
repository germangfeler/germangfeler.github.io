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

##
ggplot(humans) + 
  geom_bar(mapping = aes(x = eye_color, y = ..prop.., group = 1), stat = "count") + 
  scale_y_continuous(labels = scales::percent_format()) +  coord_flip() + theme_classic()
  
  
## Table
eyecolor <- as.data.frame(table(humans$eye_color))
colnames(eyecolor) <- c("eye_color", "n")

## Barplot
g <- ggplot(eyecolor, aes(x=reorder(eye_color, n), y=n)) + xlab("eye color")
g <- g + geom_bar(stat="identity", fill="steelblue")  + theme_classic()
g + geom_text(aes(label=n), vjust=-0.3, hjust=-0.3, size=6) +  coord_flip()

## pie chart
pie <- g+ coord_polar("y", start=0)
pie


## Table
eh <- as.data.frame(table(starwars$eye_color, starwars$hair_color))
colnames(eh) <- c("eye_color", "n")


