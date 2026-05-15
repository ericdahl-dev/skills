---
layout: default
title: crush-skills
---

<h1>crush-skills</h1>
<p>AI agent skills for real engineering work. Works with Crush, Claude Code, Cursor, Windsurf, and GitHub Copilot.</p>

<p>
  <a href="https://github.com/ericdahl-dev/skills">GitHub</a> &middot;
  <a href="https://github.com/ericdahl-dev/skills#quick-install">Install</a>
</p>

{% assign skill_files = site.skills | where_exp: "s", "s.name != nil" %}
{% assign categories = skill_files | map: "path" | map: "split: '/'" %}

{% assign engineering = skill_files | where_exp: "s", "s.path contains 'engineering'" %}
{% assign productivity = skill_files | where_exp: "s", "s.path contains 'productivity'" %}
{% assign creative = skill_files | where_exp: "s", "s.path contains 'creative'" %}
{% assign ops = skill_files | where_exp: "s", "s.path contains 'ops'" %}

{% for group in (1..4) %}
  {% if group == 1 %}{% assign cat_name = "Engineering" %}{% assign cat_skills = engineering %}{% endif %}
  {% if group == 2 %}{% assign cat_name = "Productivity" %}{% assign cat_skills = productivity %}{% endif %}
  {% if group == 3 %}{% assign cat_name = "Creative" %}{% assign cat_skills = creative %}{% endif %}
  {% if group == 4 %}{% assign cat_name = "Ops" %}{% assign cat_skills = ops %}{% endif %}

  {% if cat_skills.size > 0 %}
<h2>{{ cat_name }}</h2>
<table>
  <thead><tr><th>Skill</th><th>Description</th></tr></thead>
  <tbody>
    {% for skill in cat_skills %}
    <tr>
      <td><a href="{{ skill.url }}"><code>{{ skill.name }}</code></a></td>
      <td>{{ skill.description }}</td>
    </tr>
    {% endfor %}
  </tbody>
</table>
  {% endif %}
{% endfor %}
