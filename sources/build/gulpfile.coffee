gulp         = require 'gulp'

autoprefixer = require 'gulp-autoprefixer'
cache        = require 'gulp-cached'
cmq          = require 'gulp-combine-media-queries'
csscomb      = require 'gulp-csscomb'
coffee       = require 'gulp-coffee'
concat       = require 'gulp-concat'
cssmin       = require 'gulp-minify-css'
data         = require 'gulp-data'
gutil        = require 'gulp-util'
livereload   = require 'gulp-livereload'
less         = require 'gulp-less'
modernizr    = require 'gulp-modernizr'
nib          = require 'nib'
jade         = require 'gulp-jade'
notify       = require 'gulp-notify'
uglify       = require 'gulp-uglify'
plumber      = require 'gulp-plumber'
svgmin       = require 'gulp-svgmin'
stylus       = require 'gulp-stylus'
sequence     = require 'run-sequence'
replace      = require 'gulp-replace'
watch        = require 'gulp-watch'
imageop      = require 'gulp-image-optimization'

plugins  = [ 'jquery', 'modernizr', 'lodash', 'slick', 'bootstrap', 'browser', 'bem', 'scrollbar', 'hoverIntent', 'transit', 'fotorama', 'isotope', 'imagesLoaded', 'datepicker' ]

layout   = 'public_html/layout'
sources  = 'sources/'

path     =
	html: "#{sources}/html/"
	css:
		frontend : "#{layout}/css/"
		sources  : "#{sources}/css/"
	js:
		frontend : "#{layout}/js/"
		sources  : "#{sources}/js/"

isArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

loadPlugins = (x, y)->
	data =
		css   : []
		js    : []
		files : []

	bower   = './bower_components'
	plugins = require('./plugins.json')
	for i in x
		elm = plugins[i]
		for key of elm
			if isArray elm[key]
				for z in elm[key]
					data[key].push bower+z
			else
				data[key].push bower+elm[key]

	return data[y]


# HTML

gulp.task 'html_cache', ->
	gulp.src("#{path.html}*.jade")
	.pipe cache('html')
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe jade
		pretty: "\t"
	.pipe gulp.dest './public_html/'
	#.pipe cache('html')

gulp.task 'html', ->
	gulp.src("#{path.html}*.jade")
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe jade
		pretty: "\t"
	.pipe gulp.dest './public_html/'


# JavaScript functions

gulp.task 'js_plugins', ->
	gulp.src loadPlugins plugins, 'js'
	.pipe concat 'plugins.js'
	.pipe gulp.dest path.js.sources

gulp.task 'js_modernizr', ->
	gulp.src loadPlugins plugins, 'js'
	.pipe modernizr {
    	tests: ['csstransforms', 'csscalc'],
		options: ['testProp']
	}
	.pipe concat 'modernizr.js'
	.pipe gulp.dest path.js.sources

gulp.task 'js_coffee', ->
	gulp.src [ "#{path.js.sources}/script.coffee" ]
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe coffee()
	.pipe gulp.dest "#{path.js.sources}/"

gulp.task 'js_front', ['js_coffee'], ->
	gulp.src [ "#{path.js.sources}/plugins.js", "#{path.js.sources}/script.js" ]

	.pipe concat 'frontend.js'
	.pipe gulp.dest path.js.frontend

gulp.task 'js_mini', ->
	gulp.src [ "#{path.js.frontend}/frontend.js"]
	.pipe uglify()
	.pipe gulp.dest path.js.frontend

# CSS functions

gulp.task 'css_bootstrap', ->
	gulp.src [ "#{path.css.sources}/bootstrap/bootstrap.less" ]
	.pipe less()
	.pipe gulp.dest path.css.sources

gulp.task 'css_plugins', ->
	gulp.src(loadPlugins(plugins, 'css'))
	.pipe(concat('plugins.css'))
	.pipe(replace("background: url(", 'background: url(/layout/images/plugins/'))
	.pipe(replace("background-image: url(", 'background-image: url(/layout/images/plugins/'))
	.pipe(replace("background:url(", 'background:url(/layout/images/plugins/'))
	.pipe(replace("background-image:url(", 'background-image:url(/layout/images/plugins/'))
	.pipe gulp.dest path.css.sources

gulp.task 'css_stylus', ->
	gulp.src [ "#{path.css.sources}/style.styl" ]
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe stylus
		use: nib()
	.pipe gulp.dest path.css.sources

gulp.task 'css_front', ['css_stylus'], ->
	gulp.src [ "#{path.css.sources}/plugins.css", "#{path.css.sources}/style.css" ]
	.pipe concat 'frontend.css'
	.pipe gulp.dest path.css.frontend

gulp.task 'css_mini', ->
	gulp.src [ "#{path.css.frontend}/frontend.css"]
	.pipe gulp.dest path.css.frontend

	.pipe csscomb()
	.pipe autoprefixer
        browsers: ['last 2 versions'],
        cascade: false
    .pipe cmq
      log: true
	.pipe cssmin()



gulp.task 'copy', ->
	gulp.src loadPlugins plugins, 'files'
	.pipe gulp.dest "#{layout}/images/plugins/"

# SVG functions

gulp.task 'svg_mini', ->
	gulp.src [ "#{sources}/images/svg/**/*.svg" ]
	.pipe svgmin([{ moveGroupAttrsToElems: false },
			{ removeUselessStrokeAndFill: false },
			{ cleanupIDs: false },
			{ removeComments: true },
			{ moveGroupAttrsToElems: false },
			{ convertPathData: { straightCurves: false}}
		])
	.pipe(replace(/<desc>(.*)<\/desc>/ig, ''))
	.pipe(replace(/<title>(.*)<\/title>/ig, ''))
	.pipe gulp.dest "#{layout}/images/svg/"

gulp.task 'img_mini', ->
	gulp.src [ "#{sources}/images/**/*.jpg", "#{sources}/images/**/*.png" ]
	.pipe imageop
        optimizationLevel: 1
        progressive: true
        interlaced: true
    .pipe gulp.dest "#{layout}/images/"


# System functions

gulp.task 'reload', ->
	livereload.changed("/")

gulp.task 'ready_css', ->
	sequence 'css_bootstrap', 'css_plugins', 'css_front', 'css_mini'

gulp.task 'ready_js', ->
	sequence 'js_modernizr', 'js_plugins', 'js_front', 'js_mini'

gulp.task 'ready', ->
	sequence 'ready_css'
	sequence 'ready_js'

gulp.task 'default', ->

	livereload.listen()

	gulp.watch "#{path.js.sources}/**/*.coffee", ->
		sequence 'js_front', 'reload'

	gulp.watch "#{path.css.sources}/**/*.styl", ->
		sequence 'css_front', 'reload'

	gulp.watch "#{sources}/images/svg/**/*.svg", ->
		sequence 'svg_mini'

	gulp.watch ["#{path.html}**/*.jade"], ->
		sequence 'html_cache', 'reload'

	gulp.watch [ "#{sources}/images/**/*.jpg", "#{sources}/images/**/*.png" ], ->
		sequence 'img_mini'

	gulp.watch ["./public_html/**/*.php",'!./public_html/bitrix/**'], { 'dot' : true }, ->
		sequence 'reload'

	gulp.watch ["#{path.css.sources}/bootstrap/bootstrap.less", "./sources/build/plugins.json"], ->
		sequence 'css_bootstrap', 'css_plugins', 'copy', 'css_front', 'reload'

	gulp.watch ["./sources/build/gulpfile.coffee"], ->
		sequence 'js_plugins', 'js_front', 'css_bootstrap', 'css_plugins', 'copy', 'css_front', 'reload'

	gulp.watch ["./bower_components/**/*.js"], ->
		sequence 'js_plugins', 'js_front', 'reload'
