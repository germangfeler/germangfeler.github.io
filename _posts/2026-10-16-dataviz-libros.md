---
layout: single
title: "DataViz III: radiografía de mis lecturas"
categories: datascience
temas: [visualizacion, programacion]
tags:
  - DataViz
  - Visualización
  - ggplot2
  - R
  - tidyverse
toc: true
toc_label: "Secciones"
header:
  teaser: /assets/thumbnails/portadas/dataviz-libros.png
excerpt: "Un dataset real, de la limpieza al gráfico final"
---

<i>Previously on this blog…</i> vimos cómo [visualizar datos continuos](/datascience/shape-of-you/) y [datos categóricos](/datascience/barras-y-tortas/). A partir de un dataset de juguete fuimos conociendo diferentes gráficos. Ahora vamos a hacer algo diferente: tomar un dataset real y recorrer el camino completo desde el archivo crudo hasta los gráficos terminados.

El dataset es mi biblioteca de [Goodreads](https://www.goodreads.com/author/show/21461505.Germ_n_A_Gonz_lez), donde registro todo lo que leo desde hace años: casi 400 libros y más de 120.000 páginas. Las preguntas son las que cualquier lector se haría sobre sí mismo: ¿cuánto leo?, ¿qué leo?, ¿de dónde son los autores?, ¿leo autoras mujeres o solo hombres?, ¿coincido con el resto de los lectores en las calificaciones que doy?

## Los datos

Goodreads tenía una API para descargar los datos, pero dejó de funcionar hace tiempo. Lo que sí se puede hacer es exportar la biblioteca personal desde *My Books → Import and export*, que genera un CSV con una fila por libro: título, autor, rating propio, rating promedio, páginas, año de publicación, fecha de lectura y reseña, entre otras cosas.

A ese archivo le agregué a mano cuatro columnas que Goodreads no tiene: el país del autor, su género, el idioma en que leí el libro y si es ficción o no ficción. Con eso quedó una planilla de Excel así:

```r
> books_raw <- read_excel(here("Libros.xlsx"), sheet = "read")
> glimpse(books_raw)
Rows: 396
Columns: 14
$ Title                       <chr> "Probabilidad y estadística para ingeniería…
$ Author                      <chr> "Ronald E. Walpole", "Dennis G. Zill", "E.D…
$ Country                     <chr> "Estados Unidos", "Estados Unidos", "Argent…
$ Gender                      <chr> "Hombre", "Hombre", "Hombre", "Hombre", "Ho…
$ Language                    <chr> "Español", "Español", "Español", "Español",…
$ Type                        <chr> "No ficción", "No ficción", "No ficción", "…
$ `My Rating`                 <chr> "3", "3", "4", "4", "4", "3", "3", "3", "3"…
$ `Average Rating`            <chr> "3.62", "3.57", "3.96", "3.96", "3.98", "3.…
$ `Number of Pages`           <dbl> 816, 720, 469, 927, 639, 144, 127, 128, 144…
$ `Original Publication Year` <dbl> 2003, 2003, 1995, 1995, 1986, 1996, 1995, 1…
$ `Date Read`                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
...
```

## Limpiar antes de graficar

Un `glimpse()` ya muestra varios problemas. Los ratings son texto (`<chr>`) en lugar de números, y la fecha de lectura también. Pero el más traicionero no se ve a simple vista: en la columna de fechas, algunas celdas decían `45452`.

Ese número es una fecha en el formato interno de Excel, que cuenta los días desde el 30/12/1899 (`45452` es el 9 de junio de 2024). Pasa cuando en una misma columna conviven celdas con formato de fecha y celdas con texto: `read_excel` lee toda la columna como texto, y las fechas "de verdad" quedan convertidas en ese número. La solución es convertir los dos casos por separado:

```r
books <- books_raw %>%
  mutate(
    `Date Read` = {
      num <- suppressWarnings(as.numeric(`Date Read`))   # sólo los seriales de Excel
      case_when(
        !is.na(num) ~ as_date(num, origin = "1899-12-30"),
        TRUE        ~ as_date(parse_date_time(`Date Read`, orders = c("ymd", "mdy"),
                                              quiet = TRUE))
      )
    },
    Year_read  = year(`Date Read`),
    Month_read = month(`Date Read`, label = TRUE, abbr = TRUE),
    across(c(`My Rating`, `Average Rating`), as.numeric),
    `My Rating` = na_if(`My Rating`, 0),   # 0 = sin calificar en Goodreads
    Gender = factor(Gender, levels = c("Mujer", "Hombre"))
  )
```

Dos detalles más. En Goodreads un rating de 0 no significa "malísimo" sino "sin calificar", así que lo pasamos a `NA` para que no arrastre los promedios hacia abajo. Y la fecha de lectura falta en muchos libros (los que registré de memoria, sin saber cuándo los leí), así que todos los análisis por año van a usar solo los libros con fecha, que arrancan en 2020.

## Un esqueleto para todos los gráficos

Antes de graficar armé tres piezas que se reusan en casi todo el post. La primera es una función que muestra el gráfico y lo guarda con un nombre, para no exportar a mano:

```r
mostrar <- function(p, nombre, w = 8, h = 5) {
  ggsave(file.path(dir_fig, paste0(nombre, ".png")), p, width = w, height = h, dpi = 300)
  print(p)
  invisible(p)
}
```

La segunda es una "capa" para todos los gráficos con años en el eje X. En ggplot2 se puede guardar una lista de componentes y sumarla con `+` como si fuera uno solo:

```r
anios <- anio_desde:anio_actual
capa_anios <- list(
  scale_x_continuous(breaks = anios,
                     labels = ifelse(anios == anio_actual, paste0(anios, "*"), anios),
                     expand = expansion(mult = c(0.05, 0.25))),
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))),
  coord_cartesian(clip = "off"),
  labs(caption = paste0("* ", anio_actual, " en curso (hasta el ",
                        format(today(), "%d/%m"), ")"))
)
```

Esta capa resuelve un problema que aparece en cualquier serie temporal armada en el medio del año: el último año está incompleto, y si no se aclara, la caída de la última barra o del último punto parece una tendencia.

La tercera pieza es un filtro para etiquetar solo el último punto de cada línea, que vamos a usar enseguida:

```r
ultimo_punto <- function(df) filter(df, Year_read == max(Year_read))
```

## ¿Cuánto leo?

Empecemos por lo básico, libros y páginas por año:

```r
bp_year <- books_recent %>%
  group_by(Year_read) %>%
  summarize(Books = n(), Pages = sum(`Number of Pages`, na.rm = TRUE))

# Factor de escala para el eje secundario (redondeado a centenas)
k <- ceiling(max(bp_year$Pages) / max(bp_year$Books) / 100) * 100

ggplot(bp_year, aes(x = Year_read)) +
  geom_line(aes(y = Books), color = "blue", linewidth = 1.2) +
  geom_point(aes(y = Books), color = "blue", size = 4) +
  geom_text(aes(y = Books, label = Books), vjust = -1, color = "white") +
  geom_line(aes(y = Pages / k), color = "red", linewidth = 1.2) +
  geom_point(aes(y = Pages / k), color = "red", size = 4) +
  geom_text(aes(y = Pages / k, label = Pages), vjust = -1, color = "white") +
  geom_text(data = ultimo_punto, aes(y = Books, label = "libros"),
            hjust = 0, nudge_x = 0.15, size = 5, color = "white") +
  geom_text(data = ultimo_punto, aes(y = Pages / k, label = "páginas"),
            hjust = 0, nudge_x = 0.15, size = 5, color = "white") +
  capa_anios +
  scale_y_continuous(sec.axis = sec_axis(~ . * k, name = "Páginas"),
                     expand = expansion(mult = c(0, 0.15))) +
  xlab("Año") + ylab("Libros") +
  theme_dark_blue()
```

{:.center}
![Libros y páginas leídos por año entre 2020 y 2026: 27 libros en 2020, 19 en 2021, 27 en 2022, 36 en 2023, 35 en 2024, 38 en 2025 y 31 en lo que va de 2026](/assets/img/posts/dataviz3/01_libros_paginas_anio.png)

Nota: el doble eje es polémico pero en algunos casos como éste le veo cierta utilidad.

Del gráfico sale que, después de bajar a 19 libros en 2021, desde 2023 leo unos 35 por año. Pero los totales anuales esconden *cuándo* leí. Para eso sirve el acumulado: una línea por año con la cantidad de libros que llevaba leídos en cada día del calendario.

```r
acum <- books_recent %>%
  arrange(`Date Read`) %>%
  group_by(Year_read) %>%
  mutate(dia = yday(`Date Read`), acumulado = row_number()) %>%
  ungroup()

ggplot(acum, aes(x = dia, y = acumulado, color = factor(Year_read),
                 linewidth = Year_read == anio_actual)) +
  geom_step() +
  geom_vline(xintercept = hoy_yday, linetype = "dashed", color = "grey70") +
  geom_text_repel(data = acum %>% group_by(Year_read) %>% slice_max(dia, n = 1, with_ties = FALSE),
                  aes(label = Year_read), direction = "y", hjust = 0, nudge_x = 5,
                  segment.color = NA, size = 4, show.legend = FALSE) +
  scale_linewidth_manual(values = c(`FALSE` = 0.7, `TRUE` = 1.8), guide = "none") +
  scale_x_continuous(breaks = yday(as_date(paste0(anio_actual, "-", 1:12, "-01"))),
                     labels = month.abb, expand = expansion(mult = c(0.02, 0.08))) +
  xlab("") + ylab("Libros acumulados") +
  theme_dark_blue() +
  theme(legend.position = "none")
```

{:.center}
![Libros acumulados a lo largo del año, una línea escalonada por año desde 2020; 2026 aparece resaltado con una línea más gruesa y una línea punteada marca el día de hoy](/assets/img/posts/dataviz3/02_acumulado_anio.png)

La línea punteada marca el día de hoy, así que se puede comparar cómo viene 2026 contra los años anteriores a la misma altura del calendario. 2026 arrancó más rápido que cualquier otro año y a mitad de octubre está empatado con 2023 y 2025, los dos mejores.

Este gráfico tiene algo de carrera, así que pedía una animación. Con **gganimate** alcanza con agregar una transición al gráfico. `transition_reveal()` va dibujando las líneas a medida que avanza la variable que le indiquemos, en este caso el día del año:

```r
library(gganimate)

# acum_anim es `acum` con un punto en el día 0 para cada año y los años
# terminados extendidos hasta el 31/12 (ver el script completo al final)
anim <- ggplot(acum_anim, aes(x = dia, y = acumulado, group = anio, color = anio)) +
  geom_line(aes(linewidth = actual)) +
  geom_point(size = 3) +
  geom_text(aes(label = etiqueta), hjust = -0.3, size = 4.5, show.legend = FALSE) +
  scale_linewidth_manual(values = c(`FALSE` = 0.8, `TRUE` = 2), guide = "none") +
  scale_x_continuous(breaks = yday(as_date(paste0("2025-", 1:12, "-01"))),
                     labels = month.abb, limits = c(0, 400)) +
  labs(title = "{format(as_date(max(1, round(frame_along)), origin = '2024-12-31'), '%d/%m')}",
       x = "", y = "Libros acumulados") +
  theme_dark_blue() +
  theme(legend.position = "none") +
  transition_reveal(dia)

animacion <- animate(anim, nframes = 200, fps = 20, end_pause = 40,
                     width = 1200, height = 740, res = 150,
                     device = "ragg_png", renderer = gifski_renderer())
anim_save("acumulado_animado.gif", animacion)
```

{:.center}
![Animación de los libros acumulados por año: las líneas de cada año avanzan día a día desde enero, con la fecha en el título](/assets/img/posts/dataviz3/04_acumulado_animado.gif)

¿Y en qué meses leo más? Un gráfico de barras por mes respondería eso, pero perdería los años. Un **heatmap** con años en las filas y meses en las columnas muestra las dos cosas a la vez:

```r
# Etiqueta de año con "*" para el año en curso
lab_anio <- function(x) ifelse(x == anio_actual, paste0(x, "*"), x)

heat <- books_recent %>%
  count(Year_read, Month_read) %>%
  complete(Year_read, Month_read, fill = list(n = 0)) %>%
  # Los meses que todavía no pasaron quedan vacíos, no en cero
  mutate(n = if_else(Year_read == anio_actual & as.integer(Month_read) > month(today()),
                     NA_integer_, n),
         Year_read = factor(Year_read, levels = rev(anios), labels = lab_anio(rev(anios))))

max_n <- max(heat$n, na.rm = TRUE)

ggplot(heat, aes(x = Month_read, y = Year_read, fill = n)) +
  geom_tile(color = "grey15", linewidth = 1) +
  geom_text(aes(label = if_else(n > 0, as.character(n), ""),
                color = if_else(n > max_n * 0.6, "grey10", "white")),
            size = 4, na.rm = TRUE) +
  scale_fill_viridis_c(option = "mako", begin = 0.15, na.value = "transparent",
                       name = "Libros") +
  scale_color_identity() +
  coord_fixed() +
  xlab("") + ylab("") +
  theme_dark_blue() +
  theme(panel.grid = element_blank(), axis.line = element_blank(),
        axis.ticks = element_blank())
```

{:.center}
![Heatmap de libros leídos por mes y año entre 2020 y 2026: cada celda es un mes, con más color cuantos más libros; los máximos son enero y mayo de 2025, con 7 libros cada uno](/assets/img/posts/dataviz3/05_heatmap_calendario.png)

Se puede ver que durante el verano (especialmente diciembre y enero) es cuando más libros termino.

## ¿Qué leo?

La primera división es ficción contra no ficción:

```r
fnf_year <- books_recent %>%
  count(Type, Year_read) %>%
  complete(Type, Year_read, fill = list(n = 0))

ggplot(fnf_year, aes(x = Year_read, y = n, color = Type, group = Type)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 4) +
  geom_text(aes(label = n), vjust = -1) +
  geom_text(data = ultimo_punto, aes(label = str_to_lower(Type)),
            hjust = 0, nudge_x = 0.15, size = 5, color = "white") +
  expand_limits(y = 0) +
  capa_anios +
  xlab("Año") + ylab("Libros") +
  theme_dark_blue() +
  theme(legend.position = "none")
```

{:.center}
![Libros de ficción y no ficción por año: en 2020 están parejos, en 2021 y 2022 domina la no ficción, y desde 2023 la ficción la supera, con un pico de 28 libros en 2024](/assets/img/posts/dataviz3/10_ficcion_anio.png)

Después de un 2020 parejo, en 2021 y 2022 leí más no ficción, y en 2023 se cruzaron las líneas.

¿Y qué tan largos son los libros? En [DataViz I](/datascience/shape-of-you/) vimos histogramas y boxplots. Una herramienta que no apareció ahí son los **facets** (o *small multiples*): el mismo gráfico repetido en paneles, uno por grupo, todos con la misma escala.

```r
medianas <- books_recent %>%
  group_by(Year_read) %>%
  summarize(mediana = median(`Number of Pages`, na.rm = TRUE))

books_recent %>%
  filter(!is.na(`Number of Pages`)) %>%
  ggplot(aes(x = `Number of Pages`, fill = Type)) +
  geom_histogram(binwidth = 100, boundary = 0, color = "grey15", alpha = 0.8) +
  geom_vline(data = medianas, aes(xintercept = mediana),
             linetype = "dashed", color = "white") +
  geom_text(data = medianas, aes(x = mediana, y = Inf, label = paste("mediana:", mediana)),
            inherit.aes = FALSE, hjust = -0.1, vjust = 1.5, size = 3, color = "white") +
  facet_wrap(~ Year_read, nrow = 2, labeller = as_labeller(lab_anio)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  scale_x_continuous(breaks = c(0, 500, 1000)) +
  xlab("Páginas") + ylab("Libros") +
  theme_dark_blue() +
  theme(legend.position = "bottom", legend.title = element_blank())
```

{:.center}
![Histogramas de páginas por libro, un panel por año, con la mediana marcada: 240 páginas en 2020, 252 en 2021, 332 en 2022, 288 en 2023, 249 en 2024, 219.5 en 2025 y 240 en 2026](/assets/img/posts/dataviz3/07_paginas_facets.png)

Con una línea, `facet_wrap(~ Year_read)`, el histograma se parte en siete. La mediana de cada panel sale de un data frame aparte (`medianas`) que tiene la misma columna `Year_read`, y ggplot sabe en qué panel dibujar cada línea. Los libros se fueron acortando: de una mediana de 332 páginas en 2022 a unas 220 en 2025. Los ladrillos de más de 1.000 páginas son casi todos de la saga de *Canción de hielo y fuego*.

Otra pregunta es cuán viejos son los libros que leo. Contando por década de la publicación original:

```r
decadas <- books %>%
  filter(!is.na(`Original Publication Year`)) %>%
  mutate(decada = floor(`Original Publication Year` / 10) * 10)

decadas %>%
  filter(decada >= 1800) %>%
  count(decada, Type) %>%
  ggplot(aes(x = decada, y = n, fill = Type)) +
  geom_col(alpha = 0.8) +
  labs(caption = paste(sum(decadas$decada < 1800), "libros anteriores a 1800 no se muestran")) +
  xlab("Década de publicación original") + ylab("Libros") +
  theme_dark_blue() +
  theme(plot.caption = element_text(color = "white")) +
  labs(fill = NULL)
```

{:.center}
![Libros por década de publicación original, apilados por ficción y no ficción; la mayoría son de las décadas de 1990 a 2010, con un máximo en la de 2010](/assets/img/posts/dataviz3/08_decada_publicacion.png)

El eje empieza en 1800 porque hay tres libros mucho más antiguos (*La Odisea* entre ellos) que estirarían el eje dos milenios y aplastarían todo lo demás. La no ficción es casi toda de las últimas tres décadas, mientras que la ficción tiene una cola larga hacia atrás.

Para ver si eso cambia con los años, calculé cuántos años tenía cada libro al momento de leerlo y tomé la mediana por año:

{:.center}
![Antigüedad mediana de los libros leídos cada año: 9.5 años en 2020, 2 en 2021, 8 en 2022, 11.5 en 2023, 18 en 2024, 12.5 en 2025 y 23 en 2026](/assets/img/posts/dataviz3/09_antiguedad_anio.png)

Uso la mediana y no el promedio porque los clásicos la sesgarían: un solo libro de hace 2.800 años movería el promedio de todo un año. Este 2026 viene de clásicos.

## ¿A quién leo?

Los autores que más leí, con su foto arriba de cada barra gracias a **ggimage**:

```r
authors <- books %>%
  count(Author, sort = TRUE) %>%
  filter(n >= 4) %>%
  left_join(read_csv("autores_imagenes.csv"), by = "Author")

ggplot(authors, aes(x = reorder(Author, -n), y = n)) +
  geom_col(fill = "aquamarine", alpha = 0.5) +
  geom_text(aes(label = n), vjust = 3, color = "white") +
  geom_image(aes(image = image, y = n + 1.5), size = 0.1) +
  xlab("Autor") + ylab("Libros") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_dark_blue() +
  theme(axis.text.x = element_blank())
```

{:.center}
![Autores con al menos cuatro libros leídos, con su foto sobre cada barra; Stephen King encabeza con 19 libros](/assets/img/posts/dataviz3/12_autores.png)

¿De dónde son esos autores? En [DataViz II](/datascience/barras-y-tortas/) vimos el treemap. Acá le agregué un nivel: los países se agrupan por continente, cada continente tiene un color y los países van del tono pleno (el más leído) a tonos más claros. El continente sale de **countrycode**, a partir del nombre del país en español:

```r
nombres_es <- countrycode::codelist %>%
  select(Country = cldr.name.es, iso3 = iso3c) %>%
  filter(!is.na(Country), !is.na(iso3))

country <- books %>%
  count(Country, sort = TRUE) %>%
  left_join(nombres_es, by = "Country") %>%
  mutate(
    continente = countrycode(iso3, "iso3c", "continent", warn = FALSE),
    region     = countrycode(iso3, "iso3c", "region", warn = FALSE),
    continente = case_when(
      continente == "Americas" & region == "North America" ~ "Norteamérica",
      continente == "Americas"                             ~ "Latinoamérica",
      is.na(continente)                                    ~ "Otro",
      TRUE                                                 ~ unname(continente_es[continente])
    )
  )

# Un color base por continente, aclarándose según el ranking del país
country <- country %>%
  group_by(continente) %>%
  arrange(desc(n), .by_group = TRUE) %>%
  mutate(color = colorRampPalette(c(colores_base[[first(continente)]], "white"))(
    round(n() * 1.8) + 1)[row_number()]) %>%
  ungroup()

ggplot(country, aes(area = n, fill = color, subgroup = continente,
                    label = paste0(Country, "\n", n))) +
  geom_treemap(colour = "white") +
  geom_treemap_subgroup_border(colour = "white", size = 4) +
  geom_treemap_text(colour = "grey15", place = "centre", grow = TRUE,
                    reflow = TRUE, min.size = 3) +
  geom_treemap_subgroup_text(colour = "grey10", place = "topleft", grow = FALSE,
                             size = 14, fontface = "bold", alpha = 0.6) +
  scale_fill_identity() +
  theme_void()
```

{:.center}
![Treemap de libros por país del autor, agrupados por continente: Argentina con 134 y Estados Unidos con 129 ocupan más de la mitad; siguen Reino Unido con 29 y Francia con 24](/assets/img/posts/dataviz3/16_paises_treemap.png)

Argentina y Estados Unidos se reparten dos tercios de la biblioteca. Eso es lo que muestra el treemap, que es bueno para comparar tamaños. Para ver la geografía, en cambio, nada como un mapa. Con **sf** y **rnaturalearth** es casi gratis una vez que tenemos los códigos ISO:

```r
world <- rnaturalearth::ne_countries(scale = "small", returnclass = "sf") %>%
  left_join(country %>% filter(!is.na(iso3)) %>% select(iso3, n),
            by = c("adm0_a3" = "iso3"))

ggplot(world) +
  geom_sf(aes(fill = n), color = "grey40", linewidth = 0.1) +
  scale_fill_viridis_c(trans = "log10", na.value = "grey85", direction = -1, name = "Libros") +
  coord_sf(crs = "+proj=robin") +
  theme_void() +
  theme(plot.background = element_rect(fill = "#282C33", colour = NA),
        legend.text = element_text(colour = "white"),
        legend.title = element_text(colour = "white"))
```

{:.center}
![Mapa mundial coloreado por cantidad de libros leídos de autores de cada país, en escala logarítmica; África y gran parte de Asia aparecen en gris, sin libros](/assets/img/posts/dataviz3/17_paises_mapa.png)

El mapa deja a la vista la gran deuda: África, de donde no leí ningún libro.

Con el idioma la historia es más simple: leo el 83% en español y el resto en inglés. Y por género del autor:

```r
gender_year <- books_recent %>%
  count(Year_read, Gender) %>%
  complete(Year_read, Gender, fill = list(n = 0)) %>%
  group_by(Year_read) %>%
  mutate(total = sum(n), pct = 100 * n / total) %>%
  ungroup() %>%
  filter(Gender == "Mujer")

ggplot(gender_year, aes(x = Year_read, y = pct)) +
  geom_line(color = "orchid", linewidth = 1.2) +
  geom_point(color = "orchid", size = 4) +
  geom_text(aes(label = paste0(round(pct), "%\n(", n, "/", total, ")")),
            vjust = -0.5, color = "white", size = 3.5) +
  capa_anios +
  scale_y_continuous(limits = c(0, 100), labels = function(x) paste0(x, "%")) +
  xlab("Año") + ylab("Libros escritos por mujeres") +
  theme_dark_blue() +
  theme(plot.caption = element_text(color = "white"))
```

{:.center}
![Porcentaje de libros escritos por mujeres cada año: 15% en 2020, 26% en 2021, 11% en 2022, 17% en 2023, 29% en 2024, 45% en 2025 y 19% en 2026](/assets/img/posts/dataviz3/15_mujeres_anio.png)

En el total, solo el 16% de los libros que leí son de autoras. La etiqueta del gráfico muestra el porcentaje y el conteo entre paréntesis. 2025 fue el año más parejo.

## ¿Qué me gusta?

Goodreads guarda dos ratings por libro: el mío y el promedio de todos los usuarios. Lo natural es enfrentarlos en un scatter, con la línea y = x como referencia: arriba de la línea están los libros que me gustaron más que al resto, y abajo los que me gustaron menos.

```r
ratings <- books %>%
  filter(!is.na(`My Rating`), !is.na(`Average Rating`)) %>%
  mutate(dif = `My Rating` - `Average Rating`)

# Los 5 libros que más sobrevaloré y los 5 que más subvaloré
extremos <- bind_rows(slice_max(ratings, dif, n = 5, with_ties = FALSE),
                      slice_min(ratings, dif, n = 5, with_ties = FALSE))

ggplot(ratings, aes(x = `Average Rating`, y = `My Rating`)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey70") +
  geom_jitter(aes(color = Type), height = 0.15, width = 0, alpha = 0.6, size = 2) +
  geom_text_repel(data = extremos, aes(label = str_trunc(Title, 30)),
                  color = "white", size = 3, max.overlaps = Inf) +
  xlab("Rating promedio en Goodreads") + ylab("Mi rating") +
  theme_dark_blue() +
  labs(color = NULL)
```

{:.center}
![Diagrama de dispersión entre el rating promedio de Goodreads y mi rating para cada libro, con la recta identidad punteada y los diez libros con mayor diferencia rotulados](/assets/img/posts/dataviz3/19_rating_vs_promedio.png)

Entre los que puse mucho más alto que el promedio hay clásicos como *La Odisea* o *Cinco semanas en globo*. Entre los que puntué muy por debajo del promedio están *Annihilation* y *Por qué fracasan los países*.

El scatter muestra libro por libro. Para comparar por autor, una buena opción es el **dumbbell plot** (o gráfico de pesas): dos puntos por autor, uno para cada rating, unidos por un segmento.

```r
dumbbell <- ratings %>%
  group_by(Author) %>%
  filter(n() >= 3) %>%
  summarize(mio = mean(`My Rating`), goodreads = mean(`Average Rating`), n = n()) %>%
  mutate(Author = fct_reorder(Author, mio - goodreads))

# Fila de arriba, para rotular los puntos una sola vez en lugar de usar leyenda
fila_top <- ~ filter(.x, Author == last(levels(Author)))

ggplot(dumbbell, aes(y = Author)) +
  geom_segment(aes(x = goodreads, xend = mio, yend = Author),
               color = "grey60", linewidth = 1.2) +
  geom_point(aes(x = goodreads), color = "grey70", size = 4) +
  geom_point(aes(x = mio, color = mio > goodreads), size = 4) +
  geom_text(data = fila_top, aes(x = goodreads, label = "Goodreads"),
            vjust = -1.3, size = 3.5, color = "grey70") +
  geom_text(data = fila_top, aes(x = mio, label = "Yo"),
            vjust = -1.3, size = 3.5, color = "white") +
  scale_color_manual(values = c(`TRUE` = "aquamarine", `FALSE` = "salmon"), guide = "none") +
  scale_y_discrete(expand = expansion(add = c(0.6, 1.2))) +
  xlab("Rating promedio") + ylab("") +
  theme_dark_blue()
```

{:.center}
![Dumbbell plot con mi rating promedio y el de Goodreads para cada autor con al menos tres libros calificados, ordenados por la diferencia: arriba Philip K. Dick y Mariana Mazzucato, abajo R. L. Stine y Christopher Pike](/assets/img/posts/dataviz3/21_dumbbell_autores.png)

Arriba aparecen Philip K. Dick y Mariana Mazzucato. Abajo, R. L. Stine y Christopher Pike, a los que puntué con 3 contra más de 3,5 del promedio.

¿Y cuáles son mis autores preferidos? Para que no gane alguien por un solo libro que me encantó, me quedo con los autores de los que califiqué al menos tres libros y los ordeno por mi rating promedio. A igual promedio, primero va el que tiene más libros. Y como no es lo mismo una novela que un ensayo, armo un ranking para ficción y otro para no ficción, uno al lado del otro:

```r
preferidos <- books %>%
  filter(!is.na(`My Rating`)) %>%
  group_by(Type, Author) %>%
  summarize(rating = mean(`My Rating`), n = n(), .groups = "drop") %>%
  filter(n >= 3)

top_autores <- preferidos %>%
  group_by(Type) %>%
  slice_max(rating, n = 10) %>%
  ungroup() %>%
  arrange(Type, rating, n) %>%
  mutate(fila = fct_inorder(paste(Author, Type, sep = "___")))

ggplot(top_autores, aes(x = rating, y = fila)) +
  geom_segment(aes(x = 1, xend = rating, yend = fila), color = "grey60", linewidth = 1) +
  geom_point(color = "gold", size = 4) +
  geom_text(aes(label = paste0(round(rating, 2), " (", n, ")")),
            hjust = -0.25, color = "white", size = 3.5) +
  facet_wrap(~ Type, scales = "free_y") +
  scale_y_discrete(labels = function(x) str_remove(x, "___.*$")) +
  scale_x_continuous(limits = c(1, 6), breaks = 1:5) +
  xlab("Mi rating promedio (entre paréntesis, libros calificados)") + ylab("") +
  theme_dark_blue()
```

El truco de `fila` es para que cada panel tenga su propio orden: si el eje usara solo el nombre del autor, `facet_wrap()` compartiría un único orden entre los dos paneles. Pegándole el tipo al nombre cada fila es única, y `scale_y_discrete()` lo vuelve a sacar al momento de escribir la etiqueta.

{:.center}
![Dos gráficos de piruletas lado a lado con mis autores preferidos, entre los que califiqué al menos tres libros: en ficción encabezan Liu Cixin y J.R.R. Tolkien con 4.67; en no ficción, Matías Kulfas, Ha-Joon Chang y Juan Domingo Perón empatan con 4.5](/assets/img/posts/dataviz3/13_autores_preferidos.png)

En ficción encabezan Liu Cixin y Tolkien, con 4,67 sobre tres libros cada uno. Murakami, del que más libros califiqué en esta lista, queda más abajo con 4,12 en ocho libros. En no ficción solo tres autores llegan al mínimo de tres libros, y los tres empatan con 4,5: Matías Kulfas, Ha-Joon Chang y Juan Domingo Perón.

Lo mismo se puede hacer por país, con el mismo mínimo de tres libros. En lugar de arrancar las líneas en 1 las hago salir de mi rating promedio general (la línea punteada): así se ve de un vistazo qué países están por encima y cuáles por debajo de lo que suelo poner. El tamaño del punto indica cuántos libros hay detrás de cada promedio.

```r
rating_global <- mean(books$`My Rating`, na.rm = TRUE)

paises_rating <- books %>%
  filter(!is.na(`My Rating`), !is.na(Country)) %>%
  group_by(Country) %>%
  summarize(rating = mean(`My Rating`), n = n()) %>%
  filter(n >= 3) %>%
  arrange(rating) %>%
  mutate(Country = fct_inorder(Country))

ggplot(paises_rating, aes(x = rating, y = Country)) +
  geom_vline(xintercept = rating_global, linetype = "dashed", color = "grey70") +
  geom_segment(aes(x = rating_global, xend = rating, yend = Country),
               color = "grey60", linewidth = 1) +
  geom_point(aes(size = n), color = "gold") +
  scale_size_area(max_size = 8, name = "Libros") +
  xlab("Mi rating promedio") + ylab("") +
  theme_dark_blue()
```

{:.center}
![Países de los autores ordenados por mi rating promedio, con las líneas saliendo de mi rating promedio general, cercano a 4: arriba Rusia y Chequia con 4.5, abajo Estados Unidos, Italia y Alemania](/assets/img/posts/dataviz3/20_paises_rating.png)

Rusia y Chequia encabezan con 4,5, aunque con pocos libros detrás. Argentina, el país con más libros, queda prácticamente en mi promedio general. Estados Unidos, el segundo, queda un poco por debajo, y Alemania es el país que peor puntúo.

## Para cerrar

Si tienen cuenta en Goodreads, pueden exportar su biblioteca y probar con sus propios datos. Lo único que van a tener que agregar a mano son las columnas de país, género, idioma y tipo. Y si quieren ver qué estoy leyendo ahora, me pueden seguir en [Goodreads](https://www.goodreads.com/author/show/21461505.Germ_n_A_Gonz_lez).

Desde <a href="/assets/scripts/dataviz3_libros.R">aquí</a> pueden descargar el script completo del análisis. Los gráficos usan `theme_dark_blue()`, un tema propio que pueden descargar desde <a href="/assets/scripts/ggplot_theme_Publication-2.R">aquí</a>.
