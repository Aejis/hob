(function() {
  'use strict';

  var root    = document.getElementById('app-action-show'),
      entries = root.getElementsByTagName('li'),
      each    = Array.prototype.forEach;

  each.call(entries, function(el) {
    var info = el.getElementsByClassName('info')[0],
        log  = el.querySelector('.log pre');

    log.innerHTML = logRender(log.innerText);

    info.addEventListener('click', function(e) {
      if (el.classList.contains('opened')) {
        el.classList.remove('opened');
      } else {
        each.call(root.querySelectorAll('li.opened'), function(e) { e.classList.remove('opened'); });
        el.classList.add('opened');
      }
    }, false);
  });
})();
