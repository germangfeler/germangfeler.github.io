# theme_tinta(): tema de ggplot2 para la estética del sitio
# Blanco y negro, líneas gruesas, títulos en Courier Prime y texto en Spectral.

library(ggplot2)

# Fuentes: las mismas del sitio. Hay que instalarlas en la compu una sola vez:
#   https://fonts.google.com/specimen/Courier+Prime
#   https://fonts.google.com/specimen/Spectral
# Se usan con el dispositivo ragg (ggsave lo usa solo si está instalado el
# paquete ragg; en RStudio: Tools > Global Options > Graphics > Backend: AGG).
# Si ragg no encuentra una fuente recién instalada, reiniciá R.
fuente_titulos <- "Courier Prime"
fuente_texto   <- "Spectral"

# Paleta: tinta + los acentos de las secciones del sitio
tinta <- c(
  negro  = "#111111",
  azul   = "#2f5da8",   # Data Science
  ladrillo = "#8a4b2a", # Café
  verde  = "#1f7a5c",   # Bioinformática
  mostaza = "#c8901a",
  violeta = "#7a55a6",
  gris   = "#8c8c8c"
)

# Las etiquetas de geom_text() y geom_label() también en Spectral y en tinta
update_geom_defaults("text",  list(family = fuente_texto, colour = "#111111"))
update_geom_defaults("label", list(family = fuente_texto, colour = "#111111"))

theme_tinta <- function(base_size = 13, grilla = c("y", "x", "ambas", "ninguna")) {
  grilla <- match.arg(grilla)
  linea_grilla <- element_line(color = "#d4d4d0", linewidth = 0.4, linetype = "dotted")

  t <- theme_minimal(base_size = base_size, base_family = fuente_texto) +
    theme(
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),

      # Títulos en máquina de escribir, alineados a la izquierda del gráfico
      plot.title = element_text(family = fuente_titulos, face = "bold", size = rel(1.45),
                                color = "#111111", margin = margin(b = 4)),
      plot.subtitle = element_text(family = fuente_titulos, size = rel(1), color = "#555555",
                                   margin = margin(b = 14)),
      plot.title.position = "plot",
      plot.caption = element_text(size = rel(0.8), color = "#555555", hjust = 0,
                                  margin = margin(t = 12)),
      plot.caption.position = "plot",

      # Ejes: línea negra gruesa abajo, como los separadores del sitio
      axis.line.x  = element_line(color = "#111111", linewidth = 0.9),
      axis.ticks.x = element_line(color = "#111111", linewidth = 0.6),
      axis.ticks.length = unit(4, "pt"),
      axis.text  = element_text(color = "#111111", size = rel(0.85)),
      axis.title = element_text(family = fuente_titulos, face = "bold", size = rel(0.9)),
      axis.title.x = element_text(margin = margin(t = 8)),
      axis.title.y = element_text(margin = margin(r = 8)),

      panel.grid = element_blank(),

      # Paneles (facets) con el rótulo en un recuadro negro
      strip.background = element_rect(fill = "#111111", color = NA),
      strip.text = element_text(family = fuente_titulos, face = "bold", color = "white",
                                margin = margin(4, 6, 4, 6)),
      panel.spacing = unit(1.1, "lines"),

      legend.position = "top",
      legend.justification = "left",
      legend.title = element_blank(),
      legend.text = element_text(size = rel(0.9)),
      legend.key.size = unit(0.9, "lines"),

      plot.margin = margin(16, 18, 12, 14)
    )

  if (grilla %in% c("y", "ambas")) t <- t + theme(panel.grid.major.y = linea_grilla)
  if (grilla %in% c("x", "ambas")) t <- t + theme(panel.grid.major.x = linea_grilla)
  t
}

# Escalas con la paleta (el primer color es negro: úsenlo para la serie principal)
scale_color_tinta <- function(...) scale_color_manual(values = unname(tinta), ...)
scale_fill_tinta  <- function(...) scale_fill_manual(values = unname(tinta), ...)

# Para gráficos continuos: de blanco a tinta, o de blanco al azul del sitio
scale_fill_tinta_c <- function(alto = "#111111", ...) scale_fill_gradient(low = "#f2f2ef", high = alto, ...)

# Ejemplo -------------------------------------------------------------------
# ggplot(mpg, aes(displ, hwy, color = drv)) +
#   geom_point(size = 2.4, alpha = .85) +
#   labs(title = "Más motor, menos rendimiento",
#        subtitle = "Consumo en ruta según cilindrada",
#        x = "Cilindrada (l)", y = "Millas por galón",
#        caption = "Fuente: dataset mpg de ggplot2") +
#   scale_color_tinta() +
#   theme_tinta()
#
# ggsave("grafico.png", width = 8, height = 5, dpi = 300, bg = "white", device = ragg::agg_png)
