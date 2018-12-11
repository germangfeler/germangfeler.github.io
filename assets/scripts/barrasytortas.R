##-----------------------------------------------------
##
## DataViz II: Barras y tortas
## Autor: German A. Gonzalez
## Fecha: Nov-2018
## germangfeler.github.io/datascience/barras-y-tortas/
##
##-----------------------------------------------------

## Cargamos ggplot2 y dplyr
library(ggplot2)
library(dplyr)

## Dataset
starwars

## Nos quedamos solo con los datos de humanos
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

## Barplot de los porcentajes 
g <- ggplot(humans_pct, aes(x=eye_color, y=percentage)) + 
     geom_bar(stat="identity", fill="steelblue") + theme_classic() + coord_flip()
g
ggsave(filename="barplot2_pct.png", width=5, height=4)
  

## Barplot de color de ojos y sexo
g <- ggplot(humans, aes(eye_color)) + 
     geom_bar(aes(fill=gender)) + theme_classic()
g
ggsave(filename="barplot3.png", width=5, height=4)

## Barplot de color de ojos y sexo con barras agrupadas
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
  
## Line and points (incorrecto para este caso)
g <- ggplot(humans_pct, aes(x = reorder(eye_color, -percentage), y = percentage,  group = 1)) + 
  geom_point() + geom_line() + xlab("eye color") + theme_classic()
g  
ggsave(filename="linechart.png", width=6, height=5)

## Treemap
library("treemapify")
library("glue")

## Creamos la etiqueta con el porcentaje y la categoria
lab <- humans_pct %>%
           glue_data('{round(percentage,1)}% \n{eye_color}')

ggplot(humans_pct, aes(area = percentage, fill = eye_color, label = lab)) +
  geom_treemap()  + theme(legend.position="none") +
  geom_treemap_text(fontface = "italic", colour = "white", place = "topleft",
                    grow = TRUE) +
  scale_fill_manual(values = c("dodgerblue3", "cadetblue4", "chocolate4", "black", "burlywood4", "gold2"))                  
                    
ggsave(filename="treemap.png", width=4, height=4)


## Lollipop
ggdotchart(humans_pct, x = "eye_color", y = "n",
           sorting = "descending", add = "segments", rotate = TRUE, dot.size = 6,
           label = round(humans_pct$n), font.label = list(color = "white", size = 9, vjust = 0.5),
           ggtheme = theme_pubr())
ggsave(filename="Lollipop.png", width=6, height=6)

## Cleveland
ggdotchart(humans_pct, x = "eye_color", y = "n",
           sorting = "descending", rotate = TRUE, dot.size = 6,
           ggtheme = theme_pubr()) + theme_cleveland()
ggsave(filename="cleveland.png", width=6, height=6)
