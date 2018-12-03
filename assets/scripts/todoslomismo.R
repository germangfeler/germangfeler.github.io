##-----------------------------------------------------
##
## Todos lo mismo
## Autor: German A. Gonzalez
## Fecha: Dic-2018
## germangfeler.github.io/datascience/todos-lo-mismo/
##
##-----------------------------------------------------

## Cargamos los datos
require(RCurl)
seguro <- read.csv(text=getURL("https://raw.githubusercontent.com/stedy/Machine-Learning-with-R-datasets/master/insurance.csv"))

## Exploramos los datos
str(seguro)
head(seguro)

## Corremos una regresion entre charges y bmi
modelo1 <- lm(log(charges) ~ bmi, data=seguro)
summary(modelo1)
plot(modelo1)
