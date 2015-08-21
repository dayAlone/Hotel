delay = (ms, func) -> setTimeout func, ms

end = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'

bgSizes = []

acceptNumbers = (e)->
	if $.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) != -1 or e.keyCode == 65 and (e.ctrlKey == true or e.metaKey == true) or e.keyCode >= 35 and e.keyCode <= 40
		return
	if (e.shiftKey or e.keyCode < 48 or e.keyCode > 57) and (e.keyCode < 96 or e.keyCode > 105)
		e.preventDefault()

loadImageSize = (url, callback = (->))->
	image = new Image()
	image.src = url
	$(image).load ->
		bgSizes[url] = { width: image.width, height: image.height }
		callback()

calculateBlur = (url, parent) ->
	$parent = $(window)
	$el = $('.sidebar').elem('bg-image')
	if $el.is ':visible'
		$el.removeAttr 'style'
		$el.css { 'opacity': 0 }
		url = $('#js-sidebar-backimage-svgimage').attr('xlink:href') if !url || typeof url != 'string'
		if url
			if !bgSizes[url]
				loadImageSize url, ->
					calculateBlur url
			else

				$('#js-sidebar-backimage-svgimage').attr 'xlink:href', url
				x	   = $parent.width() / bgSizes[url].width
				y	   = $parent.height() / bgSizes[url].height
				max    = Math.max(x, y)
				height = bgSizes[url].height * max
				width  = bgSizes[url].width * max
				moveX  = $parent.width()/2 - 135

				moveY  = height/2
				$el.css
					width: width
					height: height
					opacity: 1
					marginLeft: moveX
					#marginTop: -moveY
					#translate: [moveX, moveY]

calculateLayout = ->

	$('.index').css 'minHeight', $(window).height()

	$content = $('.page').elem('content')
	$content.removeAttr('style')
	delay 300, ->
		$content.width ->
			$(this).width()

	$('body').removeClass 'open'
	$blockScroll = $('.sidebar, .side-modal')
	if $(window).width() >= 980
		if $blockScroll.data('perfect-scrollbar')
			$blockScroll.perfectScrollbar 'update'
		else
			$blockScroll.perfectScrollbar({suppressScrollX: true, includePadding: true})
	else
		$blockScroll.perfectScrollbar 'destroy'

	if $(window).width() < 760
		$('.promos.slick-initialized, .offers.slick-initialized').slick 'destroy'
	else
		if !$('.promos').hasClass 'slick-initialized'
			initPromo()
		if !$('.offers').hasClass 'slick-initialized'
			initOffers()

	if $('.promos').hasClass 'slick-initialized'
		$('.index').elem('footer').css({ opacity : 0}).find('.promos').slick 'slickGoTo', 0

	$('.slick-initialized').slick 'setPosition'

@initMap = ->
	$el = $('#map')
	coords = $el.data('coords').split ','
	map = new google.maps.Map $el[0], {
		center      : {lat: +coords[1], lng: +coords[0]}
		zoom        : $el.data 'zoom'
		scaleControl: true
		zoomControl : true
	}

sideModal = (val)->

	$('.side-modal').mod 'active', val
	if val
		$('body').addClass 'side-open'
	else
		$('body').removeClass 'side-open'

initPreviews = ->
	$('.preview').click (e)->
		$('.previews').slick 'slickGoTo', $(this).data('slick-index')
	$('.previews').on('init setPosition', ->
		delay 300, (->
			$('.previews').css { opacity : 1 }
		).bind(this)
	).on('afterChange', (event, slick, currentSlide)->
		$('.slider').data('fotorama').show(currentSlide)
	).slick
		infinite		 : true
		variableWidth    : true
		centerMode       : true
		slidesToScroll   : 1

initOffers = ->
	$('.offers').on('init setPosition', ->
		delay 300, (->
			$(this).css { opacity : 1 }
		).bind(this)
	).slick
		infinite		 : true
		autoplay         : false
		slidesToShow	 : 3
		slidesToScroll   : 1
		responsive		 : [
			{
				breakpoint    : 1225
				settings:
					slidesToShow  : 2
			}
			{
				breakpoint    : 1450
				settings:
					slidesToShow  : 3
			}
		]

initPromo = ->
	$('.index .promos')
		.on('init setPosition', ->
			delay 300, (->
				$('.index').elem('footer').css { opacity : 1 }
			).bind(this)
		).slick
			infinite		 : true
			autoplay         : false
			slidesToShow	 : 3
			arrows			 : false
			slidesToScroll   : 1
			responsive		 : [
				{
					breakpoint    : 420
					settings:
						slidesToShow  : 1
						autoplay      : true
						autoplaySpeed : 3500
				}
				{
					breakpoint    : 760
					settings:
						slidesToShow  : 2
						autoplay      : true
						autoplaySpeed : 3500
				}
				{
					breakpoint    : 1450
					settings:
						slidesToShow  : 2
						autoplay      : true
						autoplaySpeed : 3500
				}
			]

setFilterValue = ($block, id, text)->


initDropdown = ->
	$('.dropdown__item').click (e)->
		$block = $(this).block()
		id = $(this).data 'value'

		$block.elem("select").val id
		$block.find('.dropdown__trigger span').text $(this).text()
		$block.mod 'active', false

		e.preventDefault()

	$('.dropdown').hoverIntent({
		over: ->
			$(this).mod 'active', true
		out: ->
			el = $(this)
			delay 300, ->
				el.mod 'active', false
	}).elem('frame').perfectScrollbar({suppressScrollX: true, includePadding: true})

	$('.dropdown').elem('trigger').click (e)->
		e.preventDefault()


$(document).ready ->

	initDropdown()



	$('.booking').elem('date').datepicker
		language: 'ru'
		format: 'dd.mm.yyyy'
		autoclose: true

	if $.browser.mobile == true
		$('body').addClass 'mobile'

	$('.booking').elem('number').on 'keydown', acceptNumbers

	$('.side-modal').elem('close').click (e)->
		sideModal false
		e.preventDefault()

	$('.offer').click (e)->
		sideModal true
		$('.offers').slick('slickGoTo', $(this).data('slick-index'))
		$('.offers').slick 'slickPause'
		e.preventDefault()
	$('.license, .news').click (e)->
		$('.license, .news').mod 'active', false
		sideModal true
		$(this).mod 'active', true
		e.preventDefault()

	if $('#map').length > 0
		$.getScript "https://maps.googleapis.com/maps/api/js?callback=initMap"

	$('.page__trigger').click (e)->
		$('body').toggleClass 'half'
		$('.slick-initialized').slick 'slickNext'
		['left', 'right'].forEach (el)->
			if !$('.page__trigger').hasMod el
				$('.page__trigger').mod el, true
			else
				$('.page__trigger').mod el, false
		e.preventDefault()

	$('.slider').on('fotorama:ready', (e, f)->
		initPreviews()
		f.data.map (el)->
			itemBg = $(el.html).css('background-image').match(/^url\("?(.+?)"?\)$/)
			if itemBg
				loadImageSize itemBg[1]
	).on('fotorama:show', (e, f)->
			$item = $(f.activeFrame.html)
			itemBg = $item.css('background-image').match(/^url\("?(.+?)"?\)$/)
			if itemBg
				calculateBlur itemBg[1], e.target
	).on('fotorama:showend', (e, f)->
		$el = $('.previews')
		if $el.hasClass 'slick-initialized'
			current = $('.previews').slick 'slickCurrentSlide'
			if current != f.activeIndex
				$('.previews').slick 'slickGoTo', f.activeIndex
		#	$('.previews').slick 'slickNext'
	).fotorama()

	$('.sidebar .close').click (e)->
		$('body').toggleClass 'open'

	$('.nav-trigger').click (e)->
		$('body').toggleClass 'open'

		e.preventDefault()

	$(window).on 'resize', _.debounce calculateLayout, 300
	$(window).on 'resize', calculateBlur
	###
	$('.sidebar').on 'mousewheel scroll', ->
		$('.sidebar').elem('bg-image').css
			opacity: 0

	$('.sidebar').on 'mousewheel scroll', calculateBlur# _.debounce calculateBlur, 300
	###

	$(document).on 'click tap touchstart touchmove', (e)->
		if $('body').hasClass('open') && $(e.target).parents('.sidebar').length == 0 && $(e.target).parents('.nav-trigger').length == 0
				$('body').removeClass('open')
				e.preventDefault()
				e.stopPropagation()
				return false

	delay 300, ->
		calculateLayout()
		calculateBlur()
