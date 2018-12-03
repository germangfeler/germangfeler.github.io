##-----------------------------------------------------
##
## Todos lo mismo
## Autor: German A. Gonzalez
## Fecha: Dic-2018
## germangfeler.github.io/datascience/todos-lo-mismo/
##
##-----------------------------------------------------

## Cargamos los datos
library("ggplot2")
seguro <- read.csv("insurance.csv")

## Exploramos los datos
str(seguro)
head(seguro)

## Corremos una regresion entre charges y bmi
modelo1 <- lm(charges ~ bmi, data=seguro)
summary(modelo1)
par(mfrow=c(2,2))
plot(modelo1)
