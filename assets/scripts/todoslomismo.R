##-----------------------------------------------------
##
## Todos lo mismo
## Autor: German A. Gonzalez
## Fecha: Dic-2018
## germangfeler.github.io/datascience/todos-lo-mismo/
##
##-----------------------------------------------------

## Cargamos los datos
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
seguro$bmicat <- cut(seguro$bmi, breaks=c(0,25,29,100), labels=c("normal", "sobrepeso", "obeso"))

## Creamos variables dummy
seguro <- cbind(seguro, with(seguro, model.matrix(~bmicat))[,2:3])
head(seguro)

## Corremos una regresion con variables dummy
modelo2 <- lm(charges ~ bmicatobeso + bmicatsobrepreso, data=seguro)
summary(modelo2)

## ANOVA
modelo3 <- lm(charges ~ bmicat, data=seguro)
summary(modelo3)

## Solo dos categorías
seguro2 <- seguro[seguro$bmicat != "obeso", ]

## Test t
t.test(charges ~ bmicat, data=seguro2, var.equal=TRUE)
summary(lm(charges ~ bmicat, data=seguro2))

## Plot
library("ggplot2")
ggplot(data = seguro, aes(x = bmi, y = charges)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) + theme_classic()
ggsave(filename="regresion.png", width=5, height=4)






