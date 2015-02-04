(function() {
  'use strict';

  var root = dom('.app-action-show'),
      entries = root.find('li .info');

  entries.forEach(function(el) {
    var element = dom(el);

    el.addEventListener('click', function(e) {
      var parent = element.parents(1);

      if (parent.hasClass('opened')) {
        parent.removeClass('opened');
      } else {
        root.find('li.opened').removeClass('opened');
        parent.addClass('opened');
      }
    }, false);
  });

  root.find('li .log pre').forEach(function(el) {
    el.innerHTML = logRender(el.innerText);
  });
})();
