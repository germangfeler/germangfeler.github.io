---
layout: single
title: "Son todos lo mismo"
permalink: /draft2/
toc: true
toc_label: "Secciones"
header:
  teaser: /assets/thumbnails/ciencia_datos.png
excerpt: "Porqué ANOVA, regresión y test t son el mismo análisis"
---

En los cursos de estadística básica es frecuente que se vean el <strong>test t</strong>, la <strong>regresión</strong> y el <strong>análisis de la varianza</strong> (ANOVA). Lo más frecuente es que los hayamos aprendido como técnicas independientes, que se aplican a diferentes situaciones. Por eso puede resulados extraño cuando aprendemos que en realidad <strong>son todos el mismo análisis</strong>.

{:.center}
![corea](/assets/img/modelos-lineales/nick-young-meme.jpg)

¿Cómo es eso de que son todos el mismo análisis? bueno, son todos casos particulares de algo más general que se llama <strong>modelos lineales</strong>. Pero no necesitás creer en mi palabra lo podemos ver con un ejemplo práctico.

## Regresión
En este problema lo que buscamos es poder predecir cuanto le va a costar la cobertura médica a un ciudadano de Estados Unidos. Descargaremos el dataset de internet directamente a R de la siguiente forma:

```r
> require(RCurl)
> seguro <- read.csv(text=getURL("https://raw.githubusercontent.com/stedy/Machine-Learning-with-R-datasets/master/insurance.csv"))
```

Podemos ver los datos que tiene haciendo:

```r
> str(seguro)
'data.frame':   557 obs. of  7 variables:
 $ age     : int  19 33 60 62 27 19 23 30 34 59 ...
 $ sex     : Factor w/ 2 levels "female","male": 1 2 1 1 2 2 2 2 1 1 ...
 $ bmi     : num  27.9 22.7 25.8 26.3 42.1 ...
 $ children: int  0 0 0 0 0 1 0 0 1 3 ...
 $ smoker  : Factor w/ 2 levels "no","yes": 2 1 1 2 2 1 1 2 2 1 ...
 $ region  : Factor w/ 4 levels "northeast","northwest",..: 4 2 2 3 3 4 1 4 1 3 ...
 $ charges : num  16885 21984 28923 27809 39612 ...

> head(seguro)
   age    sex    bmi children smoker    region   charges
1   19 female 27.900        0    yes southwest 16884.924
4   33   male 22.705        0     no northwest 21984.471
10  60 female 25.840        0     no northwest 28923.137
12  62 female 26.290        0    yes southeast 27808.725
15  27   male 42.130        0    yes southeast 39611.758
16  19   male 24.600        1     no southwest  1837.237

```

Las variables predictivas que tenemos son:

* sexo: femenino o masculino
* bmi: índice de masa corporal (peso / altura^2) 
* children: número de hijos
* smoker: si fuma
* region: región de EE.UU. donde vive

En este ejemplo solo utilizaremos el BMI. Podemos correr una regresión simple en R de la siguiente forma:


```r
> modelo1 <- lm(charges ~ bmi, data=seguro)
```

El nombre de la función ya nos está diciendo algo: <strong>lm</strong> es el acrónimo de <strong>linear model</strong> y es la misma función que utilizaremos para el ANOVA. Para ver los resultados usamos la función <i>summary</i>:

```r
> summary(modelo1)                                                                                                                              
                                                                                                                                                
Call:                                                                                                                                           
lm(formula = charges ~ bmi, data = seguro)                                                                                                      
                                                                                                                                                
Residuals:                                                                                                                                      
   Min     1Q Median     3Q    Max                                                                                                              
-25407  -5916   -582   5784  35621                                                                                                              
                                                                                                                                                
Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) -31617.21    1628.28  -19.42   <2e-16 ***
bmi           1929.82      57.96   33.29   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
Residual standard error: 8209 on 555 degrees of freedom
Multiple R-squared:  0.6664,    Adjusted R-squared:  0.6658 
F-statistic:  1109 on 1 and 555 DF,  p-value: < 2.2e-16
```

En este caso vemos que existe una relación lineal entre los gastos en cobertura médica y el índice de masa corporal del individuo (p<0.01). Este es un caso típico de regresión: queremos ver si existe una relación lineal entre dos variables continuas.

¿Que pasaría si la variable explicativa fuera categórica? Siguiendo con el ejemplo de la cobertura médica, discreticemos la variable bmi en intervalos:
* BMI < 25: normal
* BMI >= 25 y <= 29: sobrepeso
* BMi > 29: obeso

```r
> seguro$bmicat <- ifelse(seguro$bmi < 25, "normal", "sobrepreso")
> seguro$bmicat <- ifelse(seguro$bmi > 29, "obeso", seguro$bmicat)
```

¿Cómo analizamos ahora la relación entre el costo y el bmi discretizado? una opción en ese caso sería hacer una regresión con variables dummy. Las variables dummy son variables (valga la redundancia) que solo aceptan dos valores: 1 (se cumple la condición) o 0 (no se cumple). Si tenemos 3 posibles valores como en este caso, la cantidad de variables dummy necesarias son 2. Donde bmicatobeso sea 1 indica a los sujetos obesos, donde bmicatsobrepreso sea 1 indica a los con sobrepreso y los normales son aquellos que tienen 0 en ambas variables.

```r
> seguro <- cbind(seguro, with(seguro, model.matrix(~bmicat))[,2:3])
> head(seguro)
  age    sex    bmi smoker   charges     bmicat bmicatobeso bmicatsobrepreso
1  19 female 27.900    yes 16884.924 sobrepreso           0                1
2  33   male 22.705     no 21984.471     normal           0                0
3  60 female 25.840     no 28923.137 sobrepreso           0                1
4  62 female 26.290    yes 27808.725 sobrepreso           0                1
5  27   male 42.130    yes 39611.758      obeso           1                0
6  19   male 24.600     no  1837.237     normal           0                0
```

Ahora corremos la regresión para esta variable dummy:

```r
> modelo2 <- lm(charges ~ bmicatobeso + bmicatsobrepreso, data=seguro)
> summary(modelo2)

Call:
lm(formula = charges ~ bmicatobeso + bmicatsobrepreso, data = seguro)

Residuals:
     Min       1Q   Median       3Q      Max 
-21191.9  -6148.1   -427.1   5283.0  25572.1 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)       10282.2      506.6   20.30   <2e-16 ***
bmicatobeso       26738.5      766.5   34.88   <2e-16 ***
bmicatsobrepreso   8860.7      878.6   10.09   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 7929 on 554 degrees of freedom
Multiple R-squared:  0.6893,    Adjusted R-squared:  0.6881 
F-statistic: 614.5 on 2 and 554 DF,  p-value: < 2.2e-16
```

## ANOVA

Seguramente ya se dieron cuenta de que en lugar de hacer una regresión con variables dummy podemos hacer un ANOVA usando como variable explicativa el bmi categorizado (bmicat) que defimos antes:

```r
> modelo3 <- lm(charges ~ bmicat, data=seguro)
> summary(modelo3)

Call:
lm(formula = charges ~ bmicat, data = seguro)

Residuals:
     Min       1Q   Median       3Q      Max 
-21191.9  -6148.1   -427.1   5283.0  25572.1 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)       10282.2      506.6   20.30   <2e-16 ***
bmicatobeso       26738.5      766.5   34.88   <2e-16 ***
bmicatsobrepreso   8860.7      878.6   10.09   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 7929 on 554 degrees of freedom
Multiple R-squared:  0.6893,    Adjusted R-squared:  0.6881 
F-statistic: 614.5 on 2 and 554 DF,  p-value: < 2.2e-16
```

Como ya dijimos, la función que se usa para ajustar el modelo es la misma que en el caso de la regresión: <strong>lm</strong>. Entonces, pasando en limpio: la regresión y el ANOVA son casos particulares del modelo lineal que se diferencian únicamente en la naturaleza de las explicativas. Si las explicativas son continuas estamos en presencia de una regresión, mientras que si son categóricas estamos ante un ANOVA. Cuando hacemos un ANOVA implícitamente estamos haciendo una regresión con variables dummy, por eso los resultados que obtuvimos en ambos casos son exactamente iguales (pueden chequearlo).

## Prueba t de Student
Ahora que está clara la relación entre ANOVA y regresión...

{:.center}
![pito](/assets/img/modelos-lineales/pito.jpg)
<br/>
¿Qué pito toca el test-t en todo esto?

Recordarán que el test-t para dos muestras sirve para comparar las medias de dos poblaciones con distribución normal. Es lo que utilizaríamos, por ejemplo, si queremos comparar el efecto de un medicamento con un placebo, la cantidad de masa muscular ganada mediante dos planes de entrenamiento diferentes o la cantidad promedio de queso que llevan las pizzas italianas y las argentinas.

{:.center}
![pizzas](/assets/img/modelos-lineales/pizzas.jpeg)
<br/>
<i>Me ofrezco para este experimento</i>

Siguiendo con nuestro dataset, podemos usar un test-t considerando solo a los sujetos normales y a los con sobrepreso (descartaremos de este análisis a los obesos). 

```r
> seguro2 <- seguro[seguro$bmicat != "obeso", ]
```

Ahora comparemos los resultados del test-t y de un ANOVA usando lm:

```r
> t.test(charges ~ bmicat, data=seguro2, var.equal=TRUE)

        Two Sample t-test

data:  charges by bmicat
t = -11.03, df = 365, p-value < 2.2e-16
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 -10440.43  -7281.01
sample estimates:
    mean in group normal mean in group sobrepreso 
                10282.22                 19142.95 

> summary(lm(charges ~ bmicat, data=seguro2))

Call:
lm(formula = charges ~ bmicat, data = seguro2)

Residuals:
   Min     1Q Median     3Q    Max 
-11519  -6263  -1391   4427  24787 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)       10282.2      463.2   22.20   <2e-16 ***
bmicatsobrepreso   8860.7      803.3   11.03   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 7250 on 365 degrees of freedom
Multiple R-squared:   0.25,     Adjusted R-squared:  0.2479 
F-statistic: 121.7 on 1 and 365 DF,  p-value: < 2.2e-16
```

Vemos que coinciden los valores reportados (t = 11.03, df = 365, p-value < 2.2e-16). Las medias estimadas también son idénticas   10282.22 para el grupo normal y 19142.95 para el grupo con sobrepeso (en el caso del lm este número sale de sumar los estimados del intercepto y el sobrepeso, 10282.2 + 8860.7 = 19142.9).

¿Por qué sucede esto? porque el test-t no es otra cosa que un caso particular del ANOVA (y por lo tanto del modelo lineal) donde la cantidad de tratamientos es igual a dos.









