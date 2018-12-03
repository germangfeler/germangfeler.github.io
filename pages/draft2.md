---
layout: single
title: "Son todos lo mismo"
permalink: /draft2/
header:
  teaser: /assets/thumbnails/ciencia_datos.png
excerpt: "Porqué ANOVA, regresión y test t son el mismo análisis"
---

En los cursos de estadística básica es frecuente que se vean el <strong>test t</strong>, la <strong>regresión</strong> y el <strong>análisis de la varianza</strong> (ANOVA). Lo más frecuente es que los hayamos aprendido como técnicas independientes, que se aplican a diferentes situaciones. Por eso puede resulados extraño cuando aprendemos que en realidad <strong>son todos el mismo análisis</strong>.

{:.center}
![corea](/assets/img/modelos-lineales/nick-young-meme.jpg)

¿Cómo es eso de que son todos el mismo análisis? bueno, son todos casos particulares de algo más general que se llama <strong>modelos lineales</strong>. Pero no necesitás creer en mi palabra lo podemos ver con un ejemplo práctico.

## Regresión
En este dataset, que viene del libro Machine Learning with R de Brett Lantz, se busca predecir el costo que tendrá la cobertura médica para un ciudadano de Estados Unidos. Descargaremos el dataset de internet directamente a R de la siguiente forma:

```r
> require(RCurl)
> seguro <- read.csv(text=getURL("https://raw.githubusercontent.com/stedy/Machine-Learning-with-R-datasets/master/insurance.csv"))
```

Podemos ver los datos que tiene haciendo:

```r
> str(seguro)
'data.frame':   1338 obs. of  7 variables:
 $ age     : int  19 18 28 33 32 31 46 37 37 60 ...
 $ sex     : Factor w/ 2 levels "female","male": 1 2 2 2 2 1 1 1 2 1 ...
 $ bmi     : num  27.9 33.8 33 22.7 28.9 ...
 $ children: int  0 1 3 0 0 0 1 3 2 0 ...
 $ smoker  : Factor w/ 2 levels "no","yes": 2 1 1 1 1 1 1 1 1 1 ...
 $ region  : Factor w/ 4 levels "northeast","northwest",..: 4 3 3 2 2 3 3 2 1 2 ...
 $ charges : num  16885 1726 4449 21984 3867 ...
> head(seguro)
  age    sex    bmi children smoker    region   charges
1  19 female 27.900        0    yes southwest 16884.924
2  18   male 33.770        1     no southeast  1725.552
3  28   male 33.000        3     no southeast  4449.462
4  33   male 22.705        0     no northwest 21984.471
5  32   male 28.880        0     no northwest  3866.855
6  31 female 25.740        0     no southeast  3756.622
```

Las variables predictivas que tenemos son:

* sexo: femenino o masculino
* bmi: índice de masa corporal (peso / altura^2) 
* children: número de hijos
* smoker: si fuma
* region: región de EE.UU. donde vive

En este ejemplo solo utilizaremos el BMI.
