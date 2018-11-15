---
layout: single
title: "DataViz I: Shape of You"
categories: datascience
header:
  teaser: /assets/img/dataviz/violin.png
excerpt: "Conociendo la forma de mis datos"  
---

Hablando de palabras nuevas para nombrar cosas viejas, hoy empezamos una serie de artículos sobre <i>DataViz</i>. O como decimos en criollo, visualización de datos. Un conjunto de técnicas que nos van a permitir representar gráficamente información, con el objeto de entenderla mejor o de comunicar eficientemente resultados.

Un error frecuente en analistas de datos <i>newbies</i> es querer ir directo a los bifes sin juego previo. Aunque suene tentador, hay que evitar modelar una variable sin estudiar antes su naturaleza y su forma. Ahí es donde las herramientas que veremos hoy entran en juego.

Pero primero lo primero, necesitamos un <i>dataset</i> a modo de ejemplo para trabajar. Por eso elegí <i>InsectSprays</i> una tabla con la cantidad de insectos encontrados en parcelas agrícolas tratadas con diferentes sprays de insecticidas. Con las funciones <i>head</i> y <i>tail</i> podemos ver las primeras y últimas filas de la tabla.


```{r}
> head(InsectSprays,3)
  count spray
1    10     A
2     7     A
3    20     A
> tail(InsectSprays,3)
   count spray
70    26     F
71    24     F
72    13     F

```

Para los gráficos vamos a usar un paquete llamado ggplot2, del que no vamos a entrar en detalles de la sintaxis pero la pueden consultar <a href="https://ggplot2.tidyverse.org/">aquí</a>.

```{r}
> library(ggplot2)

> ## Density
> ggplot(InsectSprays, aes(count)) + 
    geom_density(fill="grey60") +
    facet_grid(.~spray, scales="free_x") + theme_classic()
```

{:.center}
![internet](/assets/img/dataviz/density.png)
<br>
{:.center}
Density plot

```{r}
> ## Boxplot
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_boxplot() + theme_classic()

```

{:.center}
![internet](/assets/img/dataviz/boxplot.png)
<br>
{:.center}
Boxplot

```{r}
> ## Boxplot + Jitter
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_boxplot() + theme_classic() + 
     geom_jitter(shape=16, position=position_jitter(0.2))

```

{:.center}
![internet](/assets/img/dataviz/boxplot_jitter.png)
<br>
{:.center}
Boxplot + Jitter


```{r}
> ## Violin
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_violin() + theme_classic() + 
     geom_jitter(shape=16, position=position_jitter(0.2))

```

{:.center}
![internet](/assets/img/dataviz/violin.png)
<br>
{:.center}
Violin plot


```{r}
> ## Boxplot + violin  
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_violin(trim = FALSE) +
     geom_boxplot(width = 0.08, fill = "white", outlier.size = FALSE) +
     theme_classic() 
     
```

{:.center}
![internet](/assets/img/dataviz/boxplot+violin.png)
<br>
{:.center}
Boxplot + Violin plot


```{r}
> ## Beeswarm
> library("ggbeeswarm")
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_beeswarm() + theme_classic()

```

{:.center}
![internet](/assets/img/dataviz/beeswarm.png)
<br>
{:.center}
Beeswarm


```{r}
> ## joy
> library(ggjoy)
> ggplot(InsectSprays, aes(x=count, y=spray, height=..density..)) +
     geom_joy(scale=0.85) + theme_classic()

```

{:.center}
![internet](/assets/img/dataviz/joyplot.png)
<br>
{:.center}
Joy plot
