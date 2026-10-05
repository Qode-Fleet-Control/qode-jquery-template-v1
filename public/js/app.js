// jQuery runs once the DOM is ready: $(handler) is the shorthand for $(document).ready(handler).
$(function () {
  var $list = $('#task-list');

  function updateCount() {
    $('#task-count').text($list.children('li').not('.done').length);
  }

  function addTask(text) {
    $('<li>').text(text).appendTo($list);
    updateCount();
  }

  // Delegated handler: works for tasks added after the page loaded.
  $list.on('click', 'li', function () {
    $(this).toggleClass('done');
    updateCount();
  });

  $('#task-form').on('submit', function (event) {
    event.preventDefault();
    var $input = $('#task-input');
    var text = String($input.val()).trim();
    if (text) addTask(text);
    $input.val('').trigger('focus');
  });

  ['Read the README', 'Edit public/index.html', 'Ship it'].forEach(addTask);

  // Root-relative URL: the fleet serves this site at the root of its own hostname.
  $.getJSON('/data/links.json')
    .done(function (links) {
      var $links = $('#links').empty();
      $.each(links, function (_, link) {
        $('<li>').append($('<a>').attr('href', link.url).text(link.title)).appendTo($links);
      });
    })
    .fail(function () {
      $('#links').html('<li class="muted">Could not load data/links.json</li>');
    });
});
