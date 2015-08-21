(function() {
  var acceptNumbers, bgSizes, calculateBlur, calculateLayout, delay, end, initDropdown, initOffers, initPreviews, initPromo, loadImageSize, setFilterValue, sideModal;

  delay = function(ms, func) {
    return setTimeout(func, ms);
  };

  end = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd';

  bgSizes = [];

  acceptNumbers = function(e) {
    if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 || e.keyCode === 65 && (e.ctrlKey === true || e.metaKey === true) || e.keyCode >= 35 && e.keyCode <= 40) {
      return;
    }
    if ((e.shiftKey || e.keyCode < 48 || e.keyCode > 57) && (e.keyCode < 96 || e.keyCode > 105)) {
      return e.preventDefault();
    }
  };

  loadImageSize = function(url, callback) {
    var image;
    if (callback == null) {
      callback = (function() {});
    }
    image = new Image();
    image.src = url;
    return $(image).load(function() {
      bgSizes[url] = {
        width: image.width,
        height: image.height
      };
      return callback();
    });
  };

  calculateBlur = function(url, parent) {
    var $el, $parent, height, max, moveX, moveY, width, x, y;
    $parent = $(window);
    $el = $('.sidebar').elem('bg-image');
    if ($el.is(':visible')) {
      $el.removeAttr('style');
      $el.css({
        'opacity': 0
      });
      if (!url || typeof url !== 'string') {
        url = $('#js-sidebar-backimage-svgimage').attr('xlink:href');
      }
      if (url) {
        if (!bgSizes[url]) {
          return loadImageSize(url, function() {
            return calculateBlur(url);
          });
        } else {
          $('#js-sidebar-backimage-svgimage').attr('xlink:href', url);
          x = $parent.width() / bgSizes[url].width;
          y = $parent.height() / bgSizes[url].height;
          max = Math.max(x, y);
          height = bgSizes[url].height * max;
          width = bgSizes[url].width * max;
          moveX = $parent.width() / 2 - 135;
          moveY = height / 2;
          return $el.css({
            width: width,
            height: height,
            opacity: 1,
            marginLeft: moveX
          });
        }
      }
    }
  };

  calculateLayout = function() {
    var $blockScroll, $content;
    $('.index').css('minHeight', $(window).height());
    $content = $('.page').elem('content');
    $content.removeAttr('style');
    delay(300, function() {
      return $content.width(function() {
        return $(this).width();
      });
    });
    $('body').removeClass('open');
    $blockScroll = $('.sidebar, .side-modal');
    if ($(window).width() >= 980) {
      if ($blockScroll.data('perfect-scrollbar')) {
        $blockScroll.perfectScrollbar('update');
      } else {
        $blockScroll.perfectScrollbar({
          suppressScrollX: true,
          includePadding: true
        });
      }
    } else {
      $blockScroll.perfectScrollbar('destroy');
    }
    if ($(window).width() < 760) {
      $('.promos.slick-initialized, .offers.slick-initialized').slick('destroy');
    } else {
      if (!$('.promos').hasClass('slick-initialized')) {
        initPromo();
      }
      if (!$('.offers').hasClass('slick-initialized')) {
        initOffers();
      }
    }
    if ($('.promos').hasClass('slick-initialized')) {
      $('.index').elem('footer').css({
        opacity: 0
      }).find('.promos').slick('slickGoTo', 0);
    }
    return $('.slick-initialized').slick('setPosition');
  };

  this.initMap = function() {
    var $el, coords, map;
    $el = $('#map');
    coords = $el.data('coords').split(',');
    return map = new google.maps.Map($el[0], {
      center: {
        lat: +coords[1],
        lng: +coords[0]
      },
      zoom: $el.data('zoom'),
      scaleControl: true,
      zoomControl: true
    });
  };

  sideModal = function(val) {
    $('.side-modal').mod('active', val);
    if (val) {
      return $('body').addClass('side-open');
    } else {
      return $('body').removeClass('side-open');
    }
  };

  initPreviews = function() {
    $('.preview').click(function(e) {
      return $('.previews').slick('slickGoTo', $(this).data('slick-index'));
    });
    return $('.previews').on('init setPosition', function() {
      return delay(300, (function() {
        return $('.previews').css({
          opacity: 1
        });
      }).bind(this));
    }).on('afterChange', function(event, slick, currentSlide) {
      return $('.slider').data('fotorama').show(currentSlide);
    }).slick({
      infinite: true,
      variableWidth: true,
      centerMode: true,
      slidesToScroll: 1
    });
  };

  initOffers = function() {
    return $('.offers').on('init setPosition', function() {
      return delay(300, (function() {
        return $(this).css({
          opacity: 1
        });
      }).bind(this));
    }).slick({
      infinite: true,
      autoplay: false,
      slidesToShow: 3,
      slidesToScroll: 1,
      responsive: [
        {
          breakpoint: 1225,
          settings: {
            slidesToShow: 2
          }
        }, {
          breakpoint: 1450,
          settings: {
            slidesToShow: 3
          }
        }
      ]
    });
  };

  initPromo = function() {
    return $('.index .promos').on('init setPosition', function() {
      return delay(300, (function() {
        return $('.index').elem('footer').css({
          opacity: 1
        });
      }).bind(this));
    }).slick({
      infinite: true,
      autoplay: false,
      slidesToShow: 3,
      arrows: false,
      slidesToScroll: 1,
      responsive: [
        {
          breakpoint: 420,
          settings: {
            slidesToShow: 1,
            autoplay: true,
            autoplaySpeed: 3500
          }
        }, {
          breakpoint: 760,
          settings: {
            slidesToShow: 2,
            autoplay: true,
            autoplaySpeed: 3500
          }
        }, {
          breakpoint: 1450,
          settings: {
            slidesToShow: 2,
            autoplay: true,
            autoplaySpeed: 3500
          }
        }
      ]
    });
  };

  setFilterValue = function($block, id, text) {};

  initDropdown = function() {
    $('.dropdown__item').click(function(e) {
      var $block, id;
      $block = $(this).block();
      id = $(this).data('value');
      $block.elem("select").val(id);
      $block.find('.dropdown__trigger span').text($(this).text());
      $block.mod('active', false);
      return e.preventDefault();
    });
    $('.dropdown').hoverIntent({
      over: function() {
        return $(this).mod('active', true);
      },
      out: function() {
        var el;
        el = $(this);
        return delay(300, function() {
          return el.mod('active', false);
        });
      }
    }).elem('frame').perfectScrollbar({
      suppressScrollX: true,
      includePadding: true
    });
    return $('.dropdown').elem('trigger').click(function(e) {
      return e.preventDefault();
    });
  };

  $(document).ready(function() {
    initDropdown();
    $('.booking').elem('date').datepicker({
      language: 'ru',
      format: 'dd.mm.yyyy'
    });
    if ($.browser.mobile === true) {
      $('body').addClass('mobile');
    }
    $('.booking').elem('number').on('keydown', acceptNumbers);
    $('.side-modal').elem('close').click(function(e) {
      sideModal(false);
      return e.preventDefault();
    });
    $('.offer').click(function(e) {
      sideModal(true);
      $('.offers').slick('slickGoTo', $(this).data('slick-index'));
      $('.offers').slick('slickPause');
      return e.preventDefault();
    });
    $('.license, .news').click(function(e) {
      $('.license, .news').mod('active', false);
      sideModal(true);
      $(this).mod('active', true);
      return e.preventDefault();
    });
    if ($('#map').length > 0) {
      $.getScript("https://maps.googleapis.com/maps/api/js?callback=initMap");
    }
    $('.page__trigger').click(function(e) {
      $('body').toggleClass('half');
      $('.slick-initialized').slick('slickNext');
      ['left', 'right'].forEach(function(el) {
        if (!$('.page__trigger').hasMod(el)) {
          return $('.page__trigger').mod(el, true);
        } else {
          return $('.page__trigger').mod(el, false);
        }
      });
      return e.preventDefault();
    });
    $('.slider').on('fotorama:ready', function(e, f) {
      initPreviews();
      return f.data.map(function(el) {
        var itemBg;
        itemBg = $(el.html).css('background-image').match(/^url\("?(.+?)"?\)$/);
        if (itemBg) {
          return loadImageSize(itemBg[1]);
        }
      });
    }).on('fotorama:show', function(e, f) {
      var $item, itemBg;
      $item = $(f.activeFrame.html);
      itemBg = $item.css('background-image').match(/^url\("?(.+?)"?\)$/);
      if (itemBg) {
        return calculateBlur(itemBg[1], e.target);
      }
    }).on('fotorama:showend', function(e, f) {
      var $el, current;
      $el = $('.previews');
      if ($el.hasClass('slick-initialized')) {
        current = $('.previews').slick('slickCurrentSlide');
        if (current !== f.activeIndex) {
          return $('.previews').slick('slickGoTo', f.activeIndex);
        }
      }
    }).fotorama();
    $('.sidebar .close').click(function(e) {
      return $('body').toggleClass('open');
    });
    $('.nav-trigger').click(function(e) {
      $('body').toggleClass('open');
      return e.preventDefault();
    });
    $(window).on('resize', _.debounce(calculateLayout, 300));
    $(window).on('resize', calculateBlur);

    /*
    	$('.sidebar').on 'mousewheel scroll', ->
    		$('.sidebar').elem('bg-image').css
    			opacity: 0
    
    	$('.sidebar').on 'mousewheel scroll', calculateBlur# _.debounce calculateBlur, 300
     */
    $(document).on('click tap touchstart touchmove', function(e) {
      if ($('body').hasClass('open') && $(e.target).parents('.sidebar').length === 0 && $(e.target).parents('.nav-trigger').length === 0) {
        $('body').removeClass('open');
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
    });
    return delay(300, function() {
      calculateLayout();
      return calculateBlur();
    });
  });

}).call(this);
