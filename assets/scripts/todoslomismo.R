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
seguro <- read.csv("assets/datasets/insurance.csv")

## Exploramos los datos
str(seguro)
head(seguro)

## Corremos una regresion entre charges y bmi
modelo1 <- lm(charges ~ bmi, data=seguro)
summary(modelo1)
par(mfrow=c(2,2))
plot(modelo1)

## Categorizamos la variable
seguro$bmicat <- ifelse(seguro$bmi < 25, "normal", "sobrepreso")
seguro$bmicat <- ifelse(seguro$bmi > 29, "obeso", seguro$bmicat)

## Creamos variables dummy
seguro <- cbind(seguro, with(seguro, model.matrix(~bmicat))[,2:3])
head(seguro)

## Corremos una regresion con variables dummy
modelo2 <- lm(charges ~ bmicatobeso + bmicatsobrepreso, data=seguro)
summary(modelo2)

## ANOVA
modelo3 <- lm(charges ~ bmicat, data=seguro)
summary(modelo3)

