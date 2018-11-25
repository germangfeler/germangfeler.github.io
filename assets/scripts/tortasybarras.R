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

## Barplot
g <- ggplot(humans, aes(eye_color)) + 
     geom_bar(fill="steelblue") + theme_classic()
g
ggsave(filename="barplot1.png", width=5, height=4)

## Rotamos el gráfico     
g  +  coord_flip()
ggsave(filename="barplot2.png", width=5, height=4)

## Convertimos a porcentaje
humans_pct <- humans %>% 
                group_by(eye_color) %>% 
                count() %>% 
                ungroup() %>% 
                mutate(percentage=`n`/sum(`n`) * 100) 
## Barplot  
g <- ggplot(humans_pct, aes(x=eye_color, y=percentage)) + 
     geom_bar(stat="identity", fill="steelblue") + theme_classic() + coord_flip()
g
ggsave(filename="barplot2_pct.png", width=5, height=4)
  

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

## Pie chart
g <- ggplot(humans_pct) + 
     geom_bar(aes(x="", y=percentage, fill=eye_color), stat="identity", width = 1)+
     theme_void() + coord_polar("y", start=0) + 
     geom_text(aes(x=1, y = cumsum(percentage) - percentage/2, label=round(percentage,1), 
     label_pos = sum(percentage) - cumsum(percentage) + percentage / 2))
g


 