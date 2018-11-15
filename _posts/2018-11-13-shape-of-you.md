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

Para los gráficos vamos a usar un paquete llamado ggplot2, del que no vamos a entrar en detalles de la sintaxis pero la pueden consultar <a href="https://ggplot2.tidyverse.org/">aquí</a>. Nuestro objetivo es visualizar como se comportan las distribuciones de conteos de cada spray. Aprender sobre su magnitud y variabilidad nos da mucha información para luego elegir como modelar estos datos. La primera idea que tuve fue hacer un histograma, o mejor aún, un density plot que es similar pero con un suavizado que permite visualizar mejor la forma de la distribución.

```{r}
> library(ggplot2)

> ## Density
> ggplot(InsectSprays, aes(count)) + 
    geom_density(fill="grey60") +
    facet_grid(.~spray, scales="free_x") + theme_classic()
```

{:.center}
![internet](/assets/img/dataviz/density.png)

¿Cuál es el problema con este técnica? Es díficil comparar los grupos entre sí al estar en diferentes cuadros. Podríamos ponerlos en el mismo cuadro y usar transparencias pero tampoco sería un gráfico muy fácil de entender. Una alternativa mejor es el <strong>boxplot</strong>, o gráfico de cajas y tegobis*, que me gusta pensarlo como una "vista área" del histograma.

{:.center}
![internet](/assets/img/dataviz/boxplot-histograma.png)

Lo mejor del boxplot es que permite comparar a simple vista las distribuciones de diferentes grupos de datos:

```{r}
> ## Boxplot
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_boxplot() + theme_classic()

```

Podemos ver muy fácilmente que hay tres sprays medias más bajas y menor variabilidad (C, D y E), lo que implica que son más efectivos matando insectos. Podemos mejorar este gráfico agregando todos los puntos, de manera de tener un panorama más completo:

{:.center}
![internet](/assets/img/dataviz/boxplot.png)

```{r}
> ## Boxplot + Jitter
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_boxplot() + theme_classic() + 
     geom_jitter(shape=16, position=position_jitter(0.2))

```

{:.center}
![internet](/assets/img/dataviz/boxplot_jitter.png)

Todo piola con los boxplot, salvo que... los datos sean bimodales (que haya dos montañitas en su histograma, como un lomo de camello) o con distribución uniforme. Así lo mostraron los amigos Hintze y Nelson en 1998 cuando presentaron un nuevo tipo de gráfico: el <strong>violin plot</strong>.

{:.center}
![internet](/assets/img/dataviz/boxplotVsviolin.png)

Este gif (tomado de <a href="https://www.autodeskresearch.com/publications/samestats">acá</a>) muestra como datos muy diferentes pueden dar lugar al mismo boxplot pero no pueden engañar al violin plot.

{:.center}
![boxvio](/assets/img/dataviz/BoxViolinSmaller.gif)

El violin plot es una especie de híbrido entre boxplot y density plot. Para hacerlo se toma el density, se crea una copia "espejada" y se pegan juntas las dos partes. El nombre se debe a que, aparentemente, se parece a un violín pero me sumo al comentario de Rafael Ririzarry de que en realidad son más parecidos a soplillos*.

{:.center}
![sop](/assets/img/dataviz/soplillo.jpeg)

Si ahora lo aplicamos sobre nuestros datos de insecticidas tenemos:

```{r}
> ## Violin
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_violin() + theme_classic() + 
     geom_jitter(shape=16, position=position_jitter(0.2))

```

{:.center}
![violin](/assets/img/dataviz/violin.png)

Pero para qué alimentar la grieta entre boxplot y violin plot si podemos tener lo mejor de los dos mundos: 

{:.center}
![violin](/assets/img/dataviz/lomipizza.jpeg)
<br>
{:.center}
<i>Lomipizza</i>

Disculpas, me equivoqué de imagen, ahora así:

```{r}
> ## Boxplot + violin  
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_violin(trim = FALSE) +
     geom_boxplot(width = 0.08, fill = "white", outlier.size = FALSE) +
     theme_classic() 
     
```

{:.center}
![internet](/assets/img/dataviz/boxplot+violin.png)


```{r}
> ## Beeswarm
> library("ggbeeswarm")
> ggplot(InsectSprays, aes(x=spray, y=count, fill=spray)) + 
     geom_beeswarm() + theme_classic()

```

{:.center}
![internet](/assets/img/dataviz/beeswarm.png)


```{r}
> ## joy
> library(ggjoy)
> ggplot(InsectSprays, aes(x=count, y=spray, height=..density..)) +
     geom_joy(scale=0.85) + theme_classic()

```

{:.center}
![internet](/assets/img/dataviz/joyplot.png)


-----
<h2>Notas al pie</h2>

*tegobi = bigote, en lunfardo.<br>
*soplillo es la forma que tenemos en Entre Ríos (Argentina) de nombrar a los adornos del árbol de navidad. Propongo que sea adoptada por el resto del mundo hispanoparlante debido a su brevedad.
