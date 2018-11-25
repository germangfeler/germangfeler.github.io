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
                mutate(percentage=`n`/sum(`n`) * 100) %>%
                arrange(-percentage)
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
g <- ggplot(humans_pct, aes(x=1, y=percentage, fill=eye_color)) +
        geom_bar(stat="identity") +
        geom_text(aes(label = paste0(round(percentage,1),"%")), position = position_stack(vjust = 0.5))+
        coord_polar(theta = "y") + 
        theme_void()
g 
ggsave(filename="piechart.png", width=6, height=5)
  

 