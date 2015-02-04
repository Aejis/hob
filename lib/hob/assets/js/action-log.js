(function() {
  'use strict';

  var root = dom('.app-action-show'),
      log  = root.find('li');

  log.forEach(function(el) {
    el.addEventListener('click', function(e) {
      var element = dom(el);

      if (element.hasClass('opened')) {
        element.removeClass('opened');
      } else {
        root.find('li.opened').removeClass('opened');
        dom(el).addClass('opened');
      }
    }, false);
  });
})();
