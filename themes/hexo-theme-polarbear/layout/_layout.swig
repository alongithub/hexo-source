<!DOCTYPE html>
<html lang="{{ config.language }}">
  <head>
    {% include '_partial/head.swig' %}
    <title>{% block title %}{% endblock %}</title>
  </head>

  <body>
    <div id="page"  class="{% if page.toc %} hastoc {% endif %}">
      {% if page.toc %}
        {#<div id="mobelmenu">
          <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" t="1598509485579" class="icon" viewBox="0 0 1024 1024" version="1.1" p-id="11768" width="20" height="20"><defs><style type="text/css"/></defs><path d="M326.32832 304.49664a39.60832 39.60832 0 1 1 0-79.21664h535.18336a39.60832 39.60832 0 0 1 0 79.21664H326.32832zM163.84 307.2a40.96 40.96 0 1 1 0-81.92 40.96 40.96 0 0 1 0 81.92zM326.32832 550.25664a39.60832 39.60832 0 1 1 0-79.21664h535.18336a39.60832 39.60832 0 0 1 0 79.21664H326.32832zM163.84 552.96a40.96 40.96 0 1 1 0-81.92 40.96 40.96 0 0 1 0 81.92z" fill="#bfbfbf" p-id="11769"/><path d="M326.32832 796.01664a39.60832 39.60832 0 1 1 0-79.21664h535.18336a39.60832 39.60832 0 0 1 0 79.21664H326.32832zM163.84 798.72a40.96 40.96 0 1 1 0-81.92 40.96 40.96 0 0 1 0 81.92z" fill="#bfbfbf" p-id="11770"/></svg>
        </div>#}
        <div id="toc" class="toc-article">
          <div class="toc-title">目录</div>
          {{ toc(page.content, {list_number: false}) }}
        </div>
      {% endif %}
      <div class="main_wrapper">
        <header id="masthead">
          {%- include '_partial/header.swig' %}
        </header>
        <div id="content">
          
          {% block content %}{% endblock %}
        </div>

        <footer id="colophon">
          {%- include '_partial/footer.swig' %}
        </footer>

        <div class="back-to-top" id="back-to-top">
          <i class="iconfont icon-up"></i>
        </div>
      </div>
      
    </div>
    {% include '_script/comments.swig' %}
    {% include '_script/libs.swig' %}
    {% include '_script/theme.swig' %}
  </body>
</html>
