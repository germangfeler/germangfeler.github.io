##-----------------------------------------------------
##
## DataViz I: Shape of You
## Autor: German A. Gonzalez
## Fecha: Nov-2018
## germangfeler.github.io/datascience/shape-of-you/
##
##-----------------------------------------------------

## Cargamos ggplot2
library(ggplot2)

## Dataset InsectSprays
head(InsectSprays, 3)
tail(InsectSprays, 3)

## Density
ggplot(InsectSprays, aes(count)) + 
        geom_histogram(aes(y=..density..), binwidth = 2,  color = "grey30", fill = "white") +
        geom_density(alpha = .2, fill = "grey60") +
        facet_grid(.~spray, scales="free_x") + theme_classic()

ggsave(filename="density.png", width=7, height=4)


## Boxplot
ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
  geom_boxplot() + theme_classic()

ggsave(filename="boxplot.png", width=7, height=4)

## Jitter
ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
  geom_boxplot() + theme_classic() + 
  geom_jitter(shape=16, position=position_jitter(0.2))
  
ggsave(filename="boxplot_jitter.png", width=7, height=4)

## Violin
ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
  geom_violin(trim = FALSE) + theme_classic() + 
  geom_jitter(shape=16, position=position_jitter(0.2))
ggsave(filename="violin.png", width=7, height=4)

## Boxplot + violin  
ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.08, fill = "white", outlier.size = FALSE) +
  theme_classic() 
ggsave(filename="boxplot+violin.png", width=7, height=4)

## Beeswarm
library("ggbeeswarm")
ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
  geom_beeswarm() + theme_classic()
ggsave(filename="beeswarm.png", width=7, height=4)

## joy
library(ggjoy)
ggplot(InsectSprays, aes(x=count, y=spray, height=..density..)) +
  geom_joy(scale=0.85) + theme_classic()
ggsave(filename="joyplot.png", width=7, height=4)
  