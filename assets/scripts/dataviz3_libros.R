##------------------------------------------------------------------------------
## Estadísticas de Goodreads
## Autor: German Gonzalez
## Fecha: 22-04-25 (revisado 16-10-26)
## NOTA: la API de Goodreads ya no funciona, así que los datos vienen del export
## de la biblioteca personal (pasado a Libros.xlsx).
##------------------------------------------------------------------------------

library(tidyverse)
library(readxl)
library(treemapify)
library(ggimage)
library(ggrepel)
library(here)  
library(countrycode)


#options(bitmapType = "cairo")

source(here("ggplot_theme_Publication-2.R"))

##------------------------------ Parámetros ------------------------------------

anio_desde  <- 2021
anio_actual <- year(today())
hoy_yday    <- yday(today())

dir_fig <- here("figuras")
dir.create(dir_fig, showWarnings = FALSE)

# Muestra el gráfico y lo guarda en figuras/<nombre>.png
mostrar <- function(p, nombre, w = 8, h = 5) {
  print(p)
  ggsave(file.path(dir_fig, paste0(nombre, ".png")), p, width = w, height = h, dpi = 300)
  invisible(p)
}

# Eje X de años: marca el año en curso con "*" y deja lugar a la derecha
# para las etiquetas al final de cada línea
anios     <- anio_desde:anio_actual
capa_anios <- list(
  scale_x_continuous(breaks = anios,
                     labels = ifelse(anios == anio_actual, paste0(anios, "*"), anios),
                     expand = expansion(mult = c(0.05, 0.25))),   # más lugar a la derecha
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))),   # margen arriba para las etiquetas
  coord_cartesian(clip = "off"),                                   # no recorta texto en los bordes
  labs(caption = paste0("* ", anio_actual, " en curso (hasta el ",
                        format(today(), "%d/%m"), ")")),
  theme(plot.caption = element_text(color = "grey70"))
)

# Filtro para etiquetar sólo el último punto de cada línea
ultimo_punto <- function(df) filter(df, Year_read == max(Year_read))

##------------------------------ Lectura ---------------------------------------

books_raw <- read_excel(here("Libros.xlsx"), sheet = "read")
glimpse(books_raw)

books <- books_raw %>%
  mutate(
    # Goodreads exporta yyyy/mm/dd; se prueba también mm/dd/yyyy por si
    # las fechas se reformatearon en el Excel
    `Date Read` = {
      num <- suppressWarnings(as.numeric(`Date Read`))   # sólo los seriales de Excel
      case_when(
        !is.na(num) ~ as_date(num, origin = "1899-12-30"),
        TRUE        ~ as_date(parse_date_time(`Date Read`, orders = c("ymd", "mdy"), quiet = TRUE))
      )
    },
    Year_read  = year(`Date Read`),
    Month_read = month(`Date Read`, label = TRUE, abbr = TRUE),
    across(c(`My Rating`, `Average Rating`), as.numeric),
    `My Rating` = na_if(`My Rating`, 0),   # 0 = sin calificar en Goodreads
    Gender = factor(Gender, levels = c("Mujer", "Hombre"))
  )

## Control de calidad: qué se pierde en cada análisis
fechas_fallidas <- sum(!is.na(books_raw$`Date Read`) & is.na(books$`Date Read`))
if (fechas_fallidas > 0) {
  warning(fechas_fallidas, " fechas no se pudieron convertir; revisá el formato de 'Date Read'.")
}

books %>%
  summarize(total       = n(),
            sin_fecha   = sum(is.na(`Date Read`)),
            sin_paginas = sum(is.na(`Number of Pages`)),
            sin_rating  = sum(is.na(`My Rating`)),
            sin_anio_pub = sum(is.na(`Original Publication Year`)))

# Libros con fecha de lectura dentro del período analizado
books_recent <- books %>% filter(Year_read >= anio_desde)

##------------------------------ Resumen ---------------------------------------

## Totales
books %>%
  summarize(Libros = n(), Paginas = sum(`Number of Pages`, na.rm = TRUE)) %>%
  pivot_longer(everything(), names_to = "Var")
#Var      value
# Libros     396
# Paginas 120523

## Libros y páginas por año
bp_year <- books_recent %>%
  group_by(Year_read) %>%
  summarize(Books = n(), Pages = sum(`Number of Pages`, na.rm = TRUE))
bp_year
#Year_read Books Pages
#1      2021    19  5503
#2      2022    27  9337
#3      2023    36 11717
#4      2024    32  9018
#5      2025    37 10751
#6      2026    31  8590

# Factor de escala para el eje secundario (redondeado a centenas)
k <- ceiling(max(bp_year$Pages) / max(bp_year$Books) / 100) * 100

p <- ggplot(bp_year, aes(x = Year_read)) +
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
  expand_limits(y = 0) +
  xlab("Año") + ylab("Libros") +
  theme_dark_blue()
mostrar(p, "01_libros_paginas_anio")

## Lectura acumulada: cómo viene cada año a la misma altura del calendario
acum <- books_recent %>%
  arrange(`Date Read`) %>%
  group_by(Year_read) %>%
  mutate(dia = yday(`Date Read`), acumulado = row_number()) %>%
  ungroup()

# Libros leídos hasta el día de hoy en cada año
acum %>%
  filter(dia <= hoy_yday) %>%
  count(Year_read, name = "a_esta_fecha")

p <- ggplot(acum, aes(x = dia, y = acumulado, color = factor(Year_read),
                      linewidth = Year_read == anio_actual)) +
  geom_step() +
  geom_vline(xintercept = hoy_yday, linetype = "dashed", color = "grey70") +
  geom_text(data = acum %>% group_by(Year_read) %>% slice_max(dia, n = 1, with_ties = FALSE),
            aes(label = Year_read), hjust = -0.2, size = 4, show.legend = FALSE) +
  scale_linewidth_manual(values = c(`FALSE` = 0.7, `TRUE` = 1.8), guide = "none") +
  scale_x_continuous(breaks = yday(as_date(paste0(anio_actual, "-", 1:12, "-01"))),
                     labels = month.abb, expand = expansion(mult = c(0.02, 0.08))) +
  xlab("") + ylab("Libros acumulados") +
  theme_dark_blue() +
  theme(legend.position = "none")
mostrar(p, "02_acumulado_anio", w = 10)

## Estacionalidad: libros por mes (sólo años completos)
p <- books_recent %>%
  filter(Year_read < anio_actual) %>%
  count(Month_read) %>%
  ggplot(aes(x = Month_read, y = n)) +
  geom_col(fill = "aquamarine", alpha = 0.6) +
  geom_text(aes(label = n), vjust = 2, color = "white") +
  xlab("Mes") + ylab("Libros") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_dark_blue()
mostrar(p, "03_libros_mes")

##------------------------- Ficción vs no ficción ------------------------------

books %>%
  count(Type) %>%
  mutate(pct = round(100 * n / sum(n), 1))

fnf_year <- books_recent %>%
  count(Type, Year_read) %>%
  complete(Type, Year_read, fill = list(n = 0))

p <- ggplot(fnf_year, aes(x = Year_read, y = n, color = Type, group = Type)) +
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
mostrar(p, "04_ficcion_anio")

##------------------------------ Autores ---------------------------------------

authors <- books %>%
  count(Author, sort = TRUE) %>%
  filter(n >= 4)
authors

## Las imágenes se asignan por nombre desde un CSV (Author, image).
## La primera vez se crea la plantilla para completar con URLs o rutas locales.
archivo_imgs <- here("autores_imagenes.csv")
if (!file.exists(archivo_imgs)) {
  write_csv(tibble(Author = authors$Author, image = NA_character_), archivo_imgs)
  message("Se creó ", archivo_imgs, ": completá la columna 'image'.")
}
author_imgs <- read_csv(archivo_imgs, show_col_types = FALSE)

authors <- authors %>% left_join(author_imgs, by = "Author")

sin_imagen <- authors %>% filter(is.na(image)) %>% pull(Author)
if (length(sin_imagen) > 0) {
  message("Autores sin imagen en el CSV: ", paste(sin_imagen, collapse = ", "))
}

## (Opcional) Descarga las imágenes a img_autores/ y actualiza el CSV con las
## rutas locales, para no depender de URLs que pueden dejar de funcionar.
## Ejecutar una vez: descargar_imagenes()
descargar_imagenes <- function(archivo = archivo_imgs, carpeta = here("img_autores")) {
  dir.create(carpeta, showWarnings = FALSE)
  imgs <- read_csv(archivo, show_col_types = FALSE)
  for (i in which(str_detect(imgs$image, "^http"))) {
    destino <- file.path(carpeta, paste0(
      str_to_lower(str_replace_all(imgs$Author[i], "[^A-Za-z]+", "_")), ".img"))
    ok <- tryCatch({
      download.file(imgs$image[i], destino, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE)
    if (ok) imgs$image[i] <- destino else message("No se pudo descargar: ", imgs$Author[i])
  }
  write_csv(imgs, archivo)
}

p <- ggplot(authors, aes(x = reorder(Author, -n), y = n)) +
  geom_col(fill = "aquamarine", alpha = 0.5) +
  geom_text(aes(label = n), vjust = 3, color = "white") +
  geom_image(data = ~ filter(.x, !is.na(image)),
             aes(image = image, y = n + 1.5), size = 0.1) +
  # Si un autor no tiene imagen, se muestra su nombre en su lugar
  geom_text(data = ~ filter(.x, is.na(image)),
            aes(label = Author, y = n + 1), angle = 45, hjust = 0,
            size = 3, color = "white") +
  expand_limits(y = max(authors$n) + 4) +
  xlab("Autor") + ylab("Libros") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_dark_blue() +
  theme(axis.text.x = element_blank())
mostrar(p, "05_autores", w = 10)

##------------------------------ Países ----------------------------------------

nombres_es <- countrycode::codelist %>%
  select(Country = cldr.name.es, iso3 = iso3c) %>%
  filter(!is.na(Country), !is.na(iso3))

continente_es <- c(Europe = "Europa", Asia = "Asia", Africa = "África", Oceania = "Oceanía")

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

# Países que no se pudieron ubicar (quedan en "Otro")
country %>% filter(continente == "Otro")

## Un color base por continente; los países van del tono pleno (más leídos)
## a tonos más claros (menos leídos)
colores_base <- c(
  "Latinoamérica" = "#E07A5F",
  "Norteamérica"  = "#3D85C6",
  "Europa"        = "#81B29A",
  "Asia"          = "#F2CC8F",
  "África"        = "#9C6ADE",
  "Oceanía"       = "#4FB0C6",
  "Otro"          = "grey60"
)

country <- country %>%
  group_by(continente) %>%
  arrange(desc(n), .by_group = TRUE) %>%
  mutate(color = colorRampPalette(c(colores_base[[first(continente)]], "white"))(
    round(n() * 1.8) + 1)[row_number()]) %>%   # como máximo ~50% hacia el blanco
  ungroup()

p <- ggplot(country, aes(area = n, fill = color, subgroup = continente,
                         label = paste0(Country, "\n", n))) +
  geom_treemap(colour = "white") +
  geom_treemap_subgroup_border(colour = "white", size = 4) +
  geom_treemap_text(colour = "grey15", place = "centre", grow = TRUE,
                    reflow = TRUE, min.size = 3) +
  geom_treemap_subgroup_text(colour = "grey10", place = "topleft", grow = FALSE,
                             size = 14, fontface = "bold", alpha = 0.6,
                             padding.x = grid::unit(2, "mm"),
                             padding.y = grid::unit(2, "mm")) +
  scale_fill_identity() +
  theme_void()
mostrar(p, "06_paises_treemap", w = 10, h = 7)

## Mapa mundial (requiere sf y rnaturalearth; iso3 ya viene calculado en `country`)
if (all(sapply(c("sf", "rnaturalearth"), requireNamespace, quietly = TRUE))) {
  
  sin_iso <- country %>% filter(is.na(iso3)) %>% pull(Country)
  if (length(sin_iso) > 0) {
    message("Países sin código ISO (corregir a mano): ", paste(sin_iso, collapse = ", "))
  }
  
  # adm0_a3 en lugar de iso_a3: Natural Earth pone -99 a Francia y Noruega
  world <- rnaturalearth::ne_countries(scale = "small", returnclass = "sf") %>%
    left_join(country %>% filter(!is.na(iso3)) %>% select(iso3, n),
              by = c("adm0_a3" = "iso3"))
  
  p <- ggplot(world) +
    geom_sf(aes(fill = n), color = "grey40", linewidth = 0.1) +
    scale_fill_viridis_c(trans = "log10", na.value = "grey85", direction = -1, name = "Libros") +
    coord_sf(crs = "+proj=robin") +
    theme_void()
  mostrar(p, "07_paises_mapa", w = 10)
}

##------------------------------ Idioma ----------------------------------------

lang <- books %>%
  count(Language, sort = TRUE) %>%
  mutate(pct = round(100 * n / sum(n), 1))
lang

p <- ggplot(lang, aes(x = n, y = fct_reorder(Language, n))) +
  geom_col(fill = "aquamarine", alpha = 0.6) +
  geom_text(aes(label = paste0(n, " (", pct, "%)")), hjust = -0.1, color = "white") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.2))) +
  xlab("Libros") + ylab("") +
  theme_dark_blue()
mostrar(p, "08_idioma")

##------------------------------ Género ----------------------------------------

gender <- books %>%
  count(Gender) %>%
  mutate(pct = round(100 * n / sum(n), 1))
gender

p <- ggplot(gender, aes(x = "", y = n, fill = Gender)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  geom_text(aes(label = paste0(n, " (", pct, "%)")),
            position = position_stack(vjust = 0.5)) +
  theme_void()
mostrar(p, "09_genero")

## Porcentaje de autoras por año (más comparable que los conteos,
## porque el total de libros cambia mucho entre años)
gender_year <- books_recent %>%
  count(Year_read, Gender) %>%
  complete(Year_read, Gender, fill = list(n = 0)) %>%
  group_by(Year_read) %>%
  mutate(total = sum(n), pct = 100 * n / total) %>%
  ungroup() %>%
  filter(Gender == "Mujer")

p <- ggplot(gender_year, aes(x = Year_read, y = pct)) +
  geom_line(color = "orchid", linewidth = 1.2) +
  geom_point(color = "orchid", size = 4) +
  geom_text(aes(label = paste0(round(pct), "%\n(", n, "/", total, ")")),
            vjust = -0.5, color = "white", size = 3.5) +
  capa_anios +
  scale_y_continuous(limits = c(0, 100), labels = function(x) paste0(x, "%")) +
  xlab("Año") + ylab("Libros escritos por mujeres") +
  theme_dark_blue()
mostrar(p, "10_mujeres_anio")

## Género × tipo
books %>%
  count(Type, Gender) %>%
  group_by(Type) %>%
  mutate(pct = round(100 * n / sum(n), 1))

##------------------------------ Ratings ---------------------------------------

## Distribución de mis ratings por tipo
p <- books %>%
  filter(!is.na(`My Rating`)) %>%
  count(Type, `My Rating`) %>%
  ggplot(aes(x = factor(`My Rating`), y = n, fill = Type)) +
  geom_col(position = "dodge", alpha = 0.8) +
  xlab("Mi rating") + ylab("Libros") +
  theme_dark_blue()
mostrar(p, "11_ratings_distribucion")

## Mi rating vs. el promedio de Goodreads
ratings <- books %>%
  filter(!is.na(`My Rating`), !is.na(`Average Rating`)) %>%
  mutate(dif = `My Rating` - `Average Rating`)

# Diferencia media: positiva = califico por encima del consenso
ratings %>% summarize(dif_media = mean(dif), n = n())
ratings %>% group_by(Type) %>% summarize(dif_media = round(mean(dif), 2), n = n())
ratings %>% group_by(Gender) %>% summarize(rating_medio = round(mean(`My Rating`), 2), n = n())

# Autores con al menos 3 libros calificados
ratings %>%
  group_by(Author) %>%
  filter(n() >= 3) %>%
  summarize(mi_rating = round(mean(`My Rating`), 2),
            promedio_gr = round(mean(`Average Rating`), 2),
            dif = round(mean(dif), 2), n = n()) %>%
  arrange(desc(dif))

# Los 5 libros que más sobrevaloré y los 5 que más subvaloré
extremos <- bind_rows(slice_max(ratings, dif, n = 5, with_ties = FALSE),
                      slice_min(ratings, dif, n = 5, with_ties = FALSE))

p <- ggplot(ratings, aes(x = `Average Rating`, y = `My Rating`)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey70") +
  geom_jitter(aes(color = Type), height = 0.15, width = 0, alpha = 0.6, size = 2) +
  geom_text_repel(data = extremos, aes(label = str_trunc(Title, 30)),
                  color = "white", size = 3, max.overlaps = Inf) +
  xlab("Rating promedio en Goodreads") + ylab("Mi rating") +
  theme_dark_blue()
mostrar(p, "12_rating_vs_promedio", w = 9, h = 6)

##------------------------- Antigüedad de lo que leo ---------------------------

## Por década de publicación original
decadas <- books %>%
  filter(!is.na(`Original Publication Year`)) %>%
  mutate(decada = floor(`Original Publication Year` / 10) * 10)

decadas %>% filter(decada < 1800) %>% select(Title, Author, `Original Publication Year`)

p <- decadas %>%
  filter(decada >= 1800) %>%
  count(decada, Type) %>%
  ggplot(aes(x = decada, y = n, fill = Type)) +
  geom_col(alpha = 0.8) +
  labs(caption = paste(sum(decadas$decada < 1800), "libros anteriores a 1800 no se muestran")) +
  xlab("Década de publicación original") + ylab("Libros") +
  theme_dark_blue()
mostrar(p, "13_decada_publicacion", w = 10)

## Cuántos años tenía el libro cuando lo leí
edad_year <- books_recent %>%
  filter(!is.na(`Original Publication Year`)) %>%
  mutate(edad = Year_read - `Original Publication Year`) %>%
  group_by(Year_read) %>%
  summarize(mediana = median(edad), novedades = sum(edad <= 2), n = n())
edad_year

p <- ggplot(edad_year, aes(x = Year_read, y = mediana)) +
  geom_line(color = "gold", linewidth = 1.2) +
  geom_point(color = "gold", size = 4) +
  geom_text(aes(label = mediana), vjust = -1, color = "white") +
  expand_limits(y = 0) +
  capa_anios +
  xlab("Año") + ylab("Antigüedad mediana del libro (años)") +
  theme_dark_blue()
mostrar(p, "14_antiguedad_anio")

##------------------------------ Páginas ---------------------------------------

## Distribución de páginas por tipo
books %>%
  group_by(Type) %>%
  summarize(mediana = median(`Number of Pages`, na.rm = TRUE),
            media = round(mean(`Number of Pages`, na.rm = TRUE)))

p <- books %>%
  filter(!is.na(`Number of Pages`)) %>%
  ggplot(aes(x = Type, y = `Number of Pages`, fill = Type)) +
  geom_boxplot(alpha = 0.6, color = "white", outlier.color = "white") +
  xlab("") + ylab("Páginas") +
  theme_dark_blue() +
  theme(legend.position = "none")
mostrar(p, "15_paginas_tipo")

## Los 5 libros más largos
books %>%
  slice_max(`Number of Pages`, n = 5) %>%
  select(Title, Author, `Number of Pages`)
#Title                                             Author      `Number of Pages`
# A Storm of Swords (A Song of Ice and Fire, #3)    George R.R…              1177
# El conde de Montecristo                           Alexandre …              1136
# A Dance with Dragons (A Song of Ice and Fire, #5) George R.R…              1125
# A Feast for Crows (A Song of Ice and Fire, #4)    George R.R…              1060
# A Clash of Kings (A Song of Ice and Fire, #2)     George R.R…              1009
##------------------------------ Reseñas ---------------------------------------

resenias <- books %>%
  filter(!is.na(`My Review`)) %>%
  mutate(review = str_remove_all(`My Review`, "<[^>]+>"),   # quita <br/> y similares
         palabras = str_count(review, "\\S+"))

# Qué proporción de libros reseñé
books %>% summarize(reseniados = sum(!is.na(`My Review`)), total = n(),
                    pct = round(100 * reseniados / total, 1))

# ¿Escribo más cuando el libro me gustó mucho o poco?
resenias %>%
  group_by(`My Rating`) %>%
  summarize(n = n(), palabras_mediana = median(palabras))
