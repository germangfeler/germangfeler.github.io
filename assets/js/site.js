(function () {
  var root = document.documentElement;

  // Filtros de sección en la portada
  var chips = document.querySelectorAll('.chip[data-filter]');
  if (chips.length) {
    var apply = function (f) {
      chips.forEach(function (c) { c.setAttribute('aria-pressed', String(c.dataset.filter === f)); });
      document.querySelectorAll('.index [data-section]').forEach(function (el) {
        el.hidden = f !== 'all' && el.dataset.section !== f;
      });
      try { sessionStorage.setItem('filtro', f); } catch (e) {}
    };
    chips.forEach(function (c) { c.addEventListener('click', function () { apply(c.dataset.filter); }); });
    try { var saved = sessionStorage.getItem('filtro'); if (saved && document.querySelector('.chip[data-filter="' + saved + '"]')) apply(saved); } catch (e) {}
  }

  // Filtro por tema en las páginas de sección
  var tbox = document.querySelector('[data-tema-filter]');
  if (tbox) {
    var tchipsT = tbox.querySelectorAll('.chip[data-tema]');
    var rows = document.querySelectorAll('.entries .entry');
    var count = document.querySelector('[data-count]');
    var applyT = function (t, push) {
      if (!tbox.querySelector('.chip[data-tema="' + t + '"]')) t = 'todos';
      var n = 0;
      tchipsT.forEach(function (c) { c.setAttribute('aria-pressed', String(c.dataset.tema === t)); });
      rows.forEach(function (el) {
        var ok = t === 'todos' || (' ' + (el.dataset.temas || '') + ' ').indexOf(' ' + t + ' ') > -1;
        el.hidden = !ok; if (ok) n++;
      });
      if (count) count.textContent = n + (n === 1 ? ' post' : ' posts');
      if (push) {
        var url = new URL(location.href);
        if (t === 'todos') url.searchParams.delete('tema'); else url.searchParams.set('tema', t);
        history.replaceState(null, '', url);
      }
    };
    tchipsT.forEach(function (c) { c.addEventListener('click', function () { applyT(c.dataset.tema, true); }); });
    var q = new URLSearchParams(location.search).get('tema');
    if (q) applyT(q, false);
  }

  // Índice de secciones del post
  var toc = document.querySelector('[data-toc]');
  var prose = document.querySelector('.prose');
  if (toc && prose) {
    var heads = prose.querySelectorAll('h2, h3');
    var list = toc.querySelector('ol');
    var used = {};
    heads.forEach(function (h) {
      if (!h.id) {
        var base = h.textContent.trim().toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
          .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'seccion';
        var id = base, n = 2;
        while (used[id] || document.getElementById(id)) id = base + '-' + n++;
        h.id = id;
      }
      used[h.id] = true;
      var li = document.createElement('li');
      li.className = 'lvl-' + h.tagName.charAt(1);
      var a = document.createElement('a');
      a.href = '#' + h.id;
      a.textContent = h.textContent.trim();
      li.appendChild(a);
      list.appendChild(li);
    });
    if (heads.length > 1) {
      toc.hidden = false;
      if ('IntersectionObserver' in window) {
        var links = toc.querySelectorAll('a');
        var io = new IntersectionObserver(function (entries) {
          entries.forEach(function (e) {
            if (e.isIntersecting) {
              links.forEach(function (l) { l.classList.toggle('is-active', l.getAttribute('href') === '#' + e.target.id); });
            }
          });
        }, { rootMargin: '0px 0px -70% 0px' });
        heads.forEach(function (h) { io.observe(h); });
      }
    }
  }

  // Filtro de publicaciones por técnica
  var tf = document.querySelector('[data-tech-filter]');
  if (tf) {
    var tchips = tf.querySelectorAll('.tchip[data-tech]');
    var more = tf.querySelector('[data-more]');
    var status = tf.querySelector('[data-status]');
    var pubs = document.querySelectorAll('.pub');
    var label = function (slug) {
      var b = tf.querySelector('.tchip[data-tech="' + slug + '"]');
      return b ? b.firstChild.textContent.trim() : slug;
    };
    var showAll = function () {
      tf.querySelectorAll('.tchip--extra').forEach(function (c) { c.hidden = false; });
      if (more) more.hidden = true;
    };
    var setTech = function (slug, push) {
      var n = 0;
      pubs.forEach(function (p) {
        var ok = !slug || p.dataset.techs.indexOf('|' + slug + '|') !== -1;
        p.hidden = !ok; if (ok) n++;
        p.querySelectorAll('.tech').forEach(function (t) { t.classList.toggle('is-match', !!slug && t.dataset.tech === slug); });
      });
      tchips.forEach(function (c) {
        c.setAttribute('aria-pressed', String(c.dataset.tech === slug));
        if (c.dataset.tech === slug && c.hidden) showAll();
      });
      if (slug) {
        status.hidden = false;
        status.innerHTML = '';
        status.appendChild(document.createTextNode((n === 1 ? '1 trabajo' : n + ' trabajos') + ' con ' + label(slug) + '. '));
        var clear = document.createElement('button');
        clear.type = 'button'; clear.textContent = 'Ver todos';
        clear.addEventListener('click', function () { setTech(null, true); });
        status.appendChild(clear);
      } else {
        status.hidden = true;
      }
      if (push) {
        try { history.replaceState(null, '', slug ? '#tecnica=' + slug : location.pathname); } catch (e) {}
      }
    };
    tchips.forEach(function (c) {
      c.addEventListener('click', function () { setTech(c.getAttribute('aria-pressed') === 'true' ? null : c.dataset.tech, true); });
    });
    document.querySelectorAll('.pub .tech').forEach(function (t) {
      t.addEventListener('click', function () {
        setTech(t.dataset.tech, true);
        tf.scrollIntoView({ behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth', block: 'start' });
      });
    });
    if (more) {
      var extra = tf.querySelectorAll('.tchip--extra').length;
      if (!extra) more.hidden = true; else more.textContent = 'Ver todas las técnicas (+' + extra + ')';
      more.addEventListener('click', showAll);
    }
    var m = location.hash.match(/tecnica=([\w-]+)/);
    if (m) setTech(m[1], false);
  }

  // Tabla comparativa: pestañas por impuesto (celular)
  document.querySelectorAll('[data-tr]').forEach(function (tr) {
    var tabs = Array.prototype.slice.call(tr.querySelectorAll('[role="tab"]'));
    var select = function (tab, focus) {
      tabs.forEach(function (t) {
        var on = t === tab;
        t.setAttribute('aria-selected', String(on));
        t.tabIndex = on ? 0 : -1;
        document.getElementById(t.getAttribute('aria-controls')).hidden = !on;
      });
      if (focus) tab.focus();
    };
    tabs.forEach(function (t, i) {
      t.addEventListener('click', function () { select(t); });
      t.addEventListener('keydown', function (e) {
        var k = e.key, n = null;
        if (k === 'ArrowRight' || k === 'ArrowDown') n = tabs[(i + 1) % tabs.length];
        if (k === 'ArrowLeft' || k === 'ArrowUp') n = tabs[(i - 1 + tabs.length) % tabs.length];
        if (k === 'Home') n = tabs[0];
        if (k === 'End') n = tabs[tabs.length - 1];
        if (n) { e.preventDefault(); select(n, true); }
      });
    });
  });

  // Botón para copiar código
  if (navigator.clipboard) {
    document.querySelectorAll('.prose div.highlighter-rouge').forEach(function (block) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'copy-btn';
      btn.textContent = 'Copiar';
      btn.addEventListener('click', function () {
        var code = block.querySelector('code');
        navigator.clipboard.writeText(code ? code.innerText : '').then(function () {
          btn.textContent = 'Copiado';
          setTimeout(function () { btn.textContent = 'Copiar'; }, 1500);
        });
      });
      block.appendChild(btn);
    });
  }
})();
