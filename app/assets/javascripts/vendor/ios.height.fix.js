(function(){
  var setViewportHeight = (function(){
    function debounced(){
      document.documentElement.style.height = window.innerHeight + "px";
      if (document.body.scrollTop !== 0) {
          window.scrollTo(0, 0);
      }
    }
    var cancelable = null;

    return function(){
      cancelable && clearTimeout(cancelable);
      cancelable = setTimeout(debounced, 100);
    };
  })();

  //ipad safari
  if(/iPad/.test(navigator.platform) && /Safari/i.test(navigator.userAgent)){  
    window.addEventListener("resize", setViewportHeight, false);
    window.addEventListener("scroll", setViewportHeight, false);
    window.addEventListener("orientationchange", setViewportHeight, false);
    setViewportHeight();
  }
})();