---
layout: single
title: "Analizando las PASO"
categories: datascience
tags:
  - DataViz
  - Visualización
  - Mapas
  - Elecciones
  - R
header:
  teaser: /assets/thumbnails/treemap.png
toc: true
toc_label: "Secciones"
excerpt: "Usando R para leer los resultados de las PASO"  
---

Hace unos días tuvimos elecciones en Argentina. Unas multitudinarias primarias que no eligen nada pero a la vez eligieron todo. La importancia del evento, y el hecho de que los datos de cada mesa de votación son publicados en la web (ver <a href="http://descargaresultados.s3-sa-east-1.amazonaws.com/resultados.zip">aquí</a>), me hizo pensar que era una idea interesante mostrar como leer estos datos en R y hacer algunos cálculos y visualizaciones simples.

Cuando descarguen y descompriman los datos van a ver los siguientes archivos:
* descripcion_postulaciones.dsv 
* mesas_totales.dsv
* descripcion_regiones.dsv
* mesas_totales_agrp_politica.dsv
* mesas_totales_lista.dsv

En este post vamos a usar dos de ellos: mesas_totales y descripcion_postulaciones. Los pueden abrir con el bloc de notas y van a ver que son archivos de texto separados por barras verticales ("|"). ¿Cómo los leemos en R?

```r
## Cargamos los paquetes 
library("raster")
library("leaflet")
library("tidyverse")

## Seteamos el directorio de trabajo
setwd("/home/datos/paso2019/120819-054029/")

## Cargamos datos de las Mesas
mesas_lista <- read_delim("mesas_totales_lista.dsv", delim="|")
mesas_lista
glimpse(mesas_lista)
```

```r
## Descripcion postulaciones 
desc_post <- read_delim("descripcion_postulaciones.dsv", delim="|")
desc_post
glimpse(desc_post)

## Codigos provincias
desc_prov <- data.frame(CODIGO_DISTRITO = c("02", "04", "21", "01", "13", 
"23", "08", "17", "14", "05", "22", "06", "18", "16", "15", "10", 
"09", "07", "19", "11", "12", "03", "20", "24"), 
PROV = c("Buenos Aires", "Córdoba", "Santa Fe", "Ciudad de Buenos Aires","Mendoza", 
"Tucumán", "Entre Ríos", "Salta",  "Misiones", "Corrientes", "Santiago del Estero", 
"Chaco", "San Juan", "Río Negro", "Neuquén", "Jujuy", "Formosa","Chubut", 
 "San Luis", "La Pampa", "La Rioja", "Catamarca", "Santa Cruz", 
"Tierra del Fuego"))
```

Unimos dato con descripcion

```r
## Agregamos descripcion de categoria
categoria <- desc_post %>%
   select(CODIGO_CATEGORIA, NOMBRE_CATEGORIA) %>%
   distinct()

mesas <- left_join(mesas_lista, categoria, by="CODIGO_CATEGORIA") %>%
                   select(CODIGO_DISTRITO, CODIGO_AGRUPACION, NOMBRE_CATEGORIA, VOTOS_LISTA)

## Agregamos descripcion de agrup politica
agrup <- desc_post %>%
   select(CODIGO_AGRUPACION, NOMBRE_AGRUPACION) %>%
   distinct()
                   
mesas <- left_join(mesas, agrup, by="CODIGO_AGRUPACION") %>%
                   select(CODIGO_DISTRITO,NOMBRE_CATEGORIA, NOMBRE_AGRUPACION, VOTOS_LISTA)

## Agregamos nombre de provincia
mesas <- left_join(mesas, desc_prov, by="CODIGO_DISTRITO") %>%
                   select(PROV,NOMBRE_CATEGORIA, NOMBRE_AGRUPACION, VOTOS_LISTA)
                
glimpse(mesas)
```

Nos quedamos solo con las presidenciales:

```r
mesas <- mesas %>% filter(NOMBRE_CATEGORIA == "Presidente y Vicepresidente de la República")
```

Algunos cálculos simples:

```r
## Sumamos las mesas a nivel de provincia
xprov <- mesas %>% select(PROV, NOMBRE_AGRUPACION, VOTOS_LISTA) %>% 
          group_by(PROV, NOMBRE_AGRUPACION) %>% 
          summarize(VOTOS=sum(VOTOS_LISTA)) %>%
          arrange(PROV, desc(VOTOS)) 
          
xprov

## Calculamos porcentajes
xprov %<>% 
    group_by(PROV) %>%
    mutate(PCT=round(VOTOS / sum(VOTOS) * 100,2)) %>%
    ungroup()    

## Creo
xprov_wide <- xprov %>%
   select(-VOTOS) %>%
   spread(NOMBRE_AGRUPACION, PCT)
```

Creamos mapa

```r   
## Obtengo el mapa de Argentina
argentina <- getData("GADM", country="Argentina", level=1)

## Incluyo los votos en la tabla del mapa
argentina@data <- left_join(argentina@data, xprov_wide, by=c("NAME_1" = "PROV"))

## Mapa Frente de Todos
state_popup <- paste0("<strong>Provincia: </strong>", 
                      argentina$NAME_1, 
                      "<br><strong>Votos: </strong>", 
                      argentina$`FRENTE DE TODOS`,
                      " <strong>%</strong>")
pal <- colorQuantile(palette = "Blues", domain = NULL, n = 5)
                      
leaflet(data = argentina) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(fillColor = ~pal(`FRENTE DE TODOS`), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1, 
              popup = state_popup)
```

Pueden dejarme sus comentarios sobre otras cosas que les gustaría aprender o si ven algún error en el post.