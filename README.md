# germangfeler.github.io

Sitio personal de Germán A. González, hecho con Jekyll y publicado con GitHub Pages.

## Escribir un post

Crear `_posts/AAAA-MM-DD-nombre.md` con este encabezado:

```yaml
---
title: "Título del post"
categories: datascience   # datascience | bioinformatica | cafe
tags:
  - R
header:
  teaser: /assets/thumbnails/imagen.png   # miniatura del listado
excerpt: "Bajada corta"
toc: true                  # opcional: índice de secciones al costado
---
```

Para centrar una imagen, poné `{:.center}` en la línea anterior.
Para un video de YouTube: `{% include youtube.html id="ID_DEL_VIDEO" %}`.

## Agregar una publicación

Sumá una entrada en `_data/publicaciones.yml` (el archivo explica cada campo).
Las técnicas de `aporte` arman solas los filtros de /publicaciones/: usá siempre
el mismo nombre para la misma técnica para que se agrupen.
Si tenés el DOI, agregalo en `doi:` y el título pasa a ser un link al paper.

## Probar en tu compu

```bash
bundle install
bundle exec jekyll serve
```

y abrí http://localhost:4000.

## Dónde está cada cosa

- `_config.yml`: nombre, roles, links, secciones, Disqus y Google Analytics.
- `_data/navigation.yml`: menú superior.
- `_data/publicaciones.yml`: publicaciones con tu aporte en cada una.
- `pages/cv.md`: CV y resumen en números (arriba, en `stats`).
- `_layouts/` y `_includes/`: plantillas.
- `assets/css/main.css`: estilos (colores y tipografías arriba de todo).
- `assets/js/site.js`: modo oscuro, filtros, índice de secciones y botón de copiar código.
