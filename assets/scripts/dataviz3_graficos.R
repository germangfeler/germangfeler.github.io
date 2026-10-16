##------------------------------------------------------------------------------
## DataViz III: gráficos nuevos
## Se corre DESPUÉS de dataviz3_libros.R: usa books_recent, ratings, acum,
## anio_actual, hoy_yday, anios y mostrar() definidos ahí.
## Paquetes nuevos: gganimate y gifski (para exportar el GIF).
##------------------------------------------------------------------------------

library(gganimate)

## Para el post conviene guardar directo en la carpeta de imágenes del sitio:
# dir_fig <- "/ruta/a/germangfeler.github.io/assets/img/dataviz3"
# dir.create(dir_fig, showWarnings = FALSE)

# Etiqueta de año con "*" para el año en curso (se usa en ejes y facets)
lab_anio <- function(x) ifelse(x == anio_actual, paste0(x, "*"), x)

##-------------------------- 1. Heatmap calendario -----------------------------
## Año × mes en un solo gráfico: estacionalidad y evolución a la vez

heat <- books_recent %>%
  count(Year_read, Month_read) %>%
  complete(Year_read, Month_read, fill = list(n = 0)) %>%
  # Los meses que todavía no pasaron quedan vacíos, no en cero
  mutate(n = if_else(Year_read == anio_actual & as.integer(Month_read) > month(today()),
                     NA_integer_, n),
         Year_read = factor(Year_read, levels = rev(anios), labels = lab_anio(rev(anios))))

max_n <- max(heat$n, na.rm = TRUE)

p <- ggplot(heat, aes(x = Month_read, y = Year_read, fill = n)) +
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
  theme(panel.grid = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank())
mostrar(p, "16_heatmap_calendario", w = 10, h = 5)

##-------------------------- 2. Facets (small multiples) -----------------------
## Distribución de páginas por año: un panel por año, misma escala en todos

medianas <- books_recent %>%
  group_by(Year_read) %>%
  summarize(mediana = median(`Number of Pages`, na.rm = TRUE))

p <- books_recent %>%
  filter(!is.na(`Number of Pages`)) %>%
  ggplot(aes(x = `Number of Pages`, fill = Type)) +
  geom_histogram(binwidth = 100, boundary = 0, color = "grey15", alpha = 0.8) +
  geom_vline(data = medianas, aes(xintercept = mediana),
             linetype = "dashed", color = "white") +
  geom_text(data = medianas, aes(x = mediana, y = Inf, label = paste("mediana:", mediana)),
            inherit.aes = FALSE, hjust = -0.1, vjust = 1.5, size = 3, color = "white") +
  facet_wrap(~ Year_read, nrow = 2, labeller = as_labeller(lab_anio)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  xlab("Páginas") + ylab("Libros") +
  theme_dark_blue() +
  theme(legend.position = "bottom", legend.title = element_blank())
mostrar(p, "17_paginas_facets", w = 10, h = 6)

##-------------------------- 3. Dumbbell plot ----------------------------------
## Mi rating promedio vs. el de Goodreads, por autor
## (bajá el umbral de 3 libros si quedan pocos autores)

dumbbell <- ratings %>%
  group_by(Author) %>%
  filter(n() >= 3) %>%
  summarize(mio = mean(`My Rating`), goodreads = mean(`Average Rating`), n = n()) %>%
  mutate(Author = fct_reorder(Author, mio - goodreads))

# Fila de arriba, para rotular los puntos una sola vez en lugar de usar leyenda
fila_top <- ~ filter(.x, Author == last(levels(Author)))

p <- ggplot(dumbbell, aes(y = Author)) +
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
mostrar(p, "18_dumbbell_autores", w = 9, h = 6)

##-------------------------- 4. Animación del acumulado ------------------------
## La carrera de cada año: libros acumulados según el día del año

# Cada año arranca en 0 el 1 de enero, y los años terminados se extienden
# hasta el 31/12 con su total, para que todas las líneas lleguen al final
acum_anim <- acum %>%
  select(Year_read, dia, acumulado) %>%
  bind_rows(tibble(Year_read = anios, dia = 0, acumulado = 0)) %>%
  bind_rows(acum %>%
              filter(Year_read < anio_actual) %>%
              group_by(Year_read) %>%
              summarize(dia = 365, acumulado = max(acumulado))) %>%
  arrange(Year_read, dia) %>%
  mutate(actual = Year_read == anio_actual,
         anio = factor(Year_read),
         # Etiqueta como columna de texto propia; vacía en el día 0, donde
         # todos los años arrancan en el mismo punto y se superponen
         etiqueta = if_else(dia == 0, "", as.character(lab_anio(Year_read))))

anim <- ggplot(acum_anim, aes(x = dia, y = acumulado, group = anio, color = anio)) +
  geom_line(aes(linewidth = actual)) +
  geom_point(size = 3) +
  geom_text(aes(label = etiqueta), hjust = -0.3, size = 4.5, show.legend = FALSE) +
  scale_linewidth_manual(values = c(`FALSE` = 0.8, `TRUE` = 2), guide = "none") +
  scale_x_continuous(breaks = yday(as_date(paste0("2025-", 1:12, "-01"))),
                     labels = month.abb, limits = c(0, 400)) +
  # Fecha en el título: frame_along es el día del año que se está mostrando
  # (el día 0 se muestra como 01/01, no como 31/12)
  labs(title = "{format(as_date(max(1, round(frame_along)), origin = '2024-12-31'), '%d/%m')}",
       x = "", y = "Libros acumulados") +
  theme_dark_blue() +
  theme(legend.position = "none") +
  transition_reveal(dia)

# end_pause deja quieto el último cuadro antes de que el GIF vuelva a empezar.
# device = "ragg_png" dibuja cada cuadro con antialiasing (sin él, el texto y
# las líneas salen pixelados); res más alta = texto más nítido.
animacion <- animate(anim, nframes = 200, fps = 20, end_pause = 40,
                     width = 1200, height = 740, res = 150,
                     device = "ragg_png",
                     renderer = gifski_renderer())
animacion
anim_save(file.path(dir_fig, "19_acumulado_animado.gif"), animacion)

## Alternativa: MP4 (requiere el paquete av). Mucho más nítido y liviano que
## el GIF, porque el GIF está limitado a 256 colores por cuadro.
# video <- animate(anim, nframes = 200, fps = 20, end_pause = 40,
#                  width = 1200, height = 740, res = 150,
#                  device = "ragg_png", renderer = av_renderer())
# anim_save(file.path(dir_fig, "19_acumulado_animado.mp4"), video)
