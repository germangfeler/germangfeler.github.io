---
layout: page
permalink: /datascience/
title: Data Science
---

Posts sobre Data Science, R y estadística.

{% for post in site.categories.datascience %}
 <li><span>{{ post.date | date_to_string }}</span> &nbsp; <a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
