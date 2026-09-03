/* FETCH — shared nav behaviour: mobile drawer, demo dropdown, active link */
(function () {
  var body = document.body;
  var toggle = document.querySelector('.nav-toggle');
  var drop = document.querySelector('.nav-drop');

  if (toggle) {
    toggle.addEventListener('click', function () {
      var open = body.classList.toggle('nav-open');
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
  }

  if (drop) {
    var dropBtn = drop.querySelector('button');
    dropBtn.addEventListener('click', function (e) {
      e.stopPropagation();
      var open = drop.getAttribute('data-open') === 'true';
      drop.setAttribute('data-open', open ? 'false' : 'true');
      dropBtn.setAttribute('aria-expanded', open ? 'false' : 'true');
    });
    document.addEventListener('click', function (e) {
      if (!drop.contains(e.target)) {
        drop.setAttribute('data-open', 'false');
        dropBtn.setAttribute('aria-expanded', 'false');
      }
    });
  }

  document.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return;
    body.classList.remove('nav-open');
    if (toggle) toggle.setAttribute('aria-expanded', 'false');
    if (drop) drop.setAttribute('data-open', 'false');
  });

  /* close the drawer when a link inside it is tapped */
  document.querySelectorAll('.nav-links a').forEach(function (a) {
    a.addEventListener('click', function () {
      body.classList.remove('nav-open');
      if (toggle) toggle.setAttribute('aria-expanded', 'false');
    });
  });

  /* mark the current page */
  var here = location.pathname.replace(/index\.html$/, '') || '/';
  document.querySelectorAll('.nav-links > a[href]').forEach(function (a) {
    var href = a.getAttribute('href');
    if (!href || href.charAt(0) === '#') return;
    if (href.replace(/index\.html$/, '') === here) a.setAttribute('aria-current', 'page');
  });

  /* reset drawer state if resized up to desktop */
  var mq = window.matchMedia('(min-width:1081px)');
  var reset = function () {
    if (mq.matches) {
      body.classList.remove('nav-open');
      if (toggle) toggle.setAttribute('aria-expanded', 'false');
    }
  };
  mq.addEventListener ? mq.addEventListener('change', reset) : window.addEventListener('resize', reset);
})();
