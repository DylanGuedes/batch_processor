// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import "./semantic.min.js";
import "./phoenix_html.js";

$(document).ready(function() {
  $('.menu .item').tab();

  $('.trigger-required-params').on('click', function() {
    var handlerSlug = (this).getAttribute('handler-slug');
    $('.ui.modal#required-params-'+handlerSlug).modal('show');
  });

  $('.trigger-optional-params').on('click', function() {
    var handlerSlug = (this).getAttribute('handler-slug');
    $('.ui.modal#optional-params-'+handlerSlug).modal('show');
  });

  $('.has-popup').popup({});

  $('.search-logs').on('click', function() {
    var uuid = (this).getAttribute('data');
    $.ajax({
      dataType: "json",
      url: "/api/retrieve_log",
      data: {"job_id": uuid},
      success: function(data) {
        var AU = require('ansi_up');
        var ansi_up = new AU.default;
        var html = ansi_up.ansi_to_html(data);
        var d = document.createElement('div');
        d.innerHTML = html;
        $('.job-log').replaceWith(html);
      }
    });
    $('.ui.modal#'+uuid).modal('show');
  });
});
