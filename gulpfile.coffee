gulp = require 'gulp'
gulpif = require 'gulp-if'
plumber = require 'gulp-plumber'
notify = require 'gulp-notify'
runSequence = require 'run-sequence'
browser = require 'browser-sync'
sourcemaps = require 'gulp-sourcemaps'
del = require 'del'
env = process.env.NODE_ENV

# html
pug = require 'gulp-pug'
fs = require 'fs'
data = require 'gulp-data'
path = require 'path'
# css
sass = require 'gulp-sass'
sassGlob = require 'gulp-sass-glob'
cleancss = require 'gulp-clean-css'
autoprefixer = require 'gulp-autoprefixer'
# js
webpack = require 'webpack-stream'
webpackConfig = require './webpack.config.coffee'

# directories
dir =
	src:
		html: './src/pug/'
		json: './src/pug/_data/'
		css: './src/sass/'
		js: './src/ts'
	dist:
		html: './dist/'
		css: './dist/assets/css/'
		js: './dist/assets/js/'

gulp.task 'clean', ->
	del ["#{dir.dist.css}**", "#{dir.dist.js}**"]

gulp.task 'html', ->
	locals =
		site: JSON.parse fs.readFileSync("#{dir.src.json}site.json")

	gulp.src ["#{dir.src.html}**/*.pug", "!#{dir.src.html}**/_*.pug"]
		.pipe plumber {
			errorHandler: notify.onError "Error: <%= error.message %>"
		}
		.pipe data (file)->
			_path = file.path
				.replace(/\.pug$/, '.html')
				.replace(/\index\.html$/, '/')
			locals.pagePath = path.relative file.base, _path
			locals
		.pipe pug
			locals: locals
			basedir: dir.src.html
			pretty: true
		.pipe gulp.dest dir.dist.html
		.pipe browser.reload {stream:true}


gulp.task "css", ->
	gulp.src "#{dir.src.css}/**/*.scss"
		.pipe sassGlob()
		.pipe plumber {
			errorHandler: notify.onError "Error: <%= error.message %>"
		}
		.pipe sourcemaps.init()
		.pipe sass().on('error', sass.logError)
		.pipe autoprefixer()
		.pipe cleancss()
		.pipe gulpif( env isnt 'build', sourcemaps.write('.') )
		.pipe gulp.dest dir.dist.css
		.pipe browser.reload {stream:true}


gulp.task 'js', ->
	gulp.src "#{dir.src.js}**/*.ts"
		.pipe plumber {
			errorHandler: notify.onError "Error: <%= error.message %>"
		}
		.pipe webpack webpackConfig
		.pipe gulp.dest dir.dist.js
		.pipe browser.reload {stream:true}


gulp.task 'serve', ->
	# browser.init
	# 	proxy:
	# 		target: ""
	browser {
		server: {
			baseDir: dir.dist.html
		}
	}

gulp.task 'watch', ->
	gulp.watch "#{dir.src.html}**/*.pug", ['html']
	gulp.watch "#{dir.src.css}**/*.scss", ['css']
	gulp.watch "#{dir.src.js}**/*.ts", ['js']

gulp.task 'default', ->
	if env is 'build'
		runSequence 'clean', ['html', 'css', 'js']
	else
		runSequence ['html', 'css', 'js'], 'watch', 'serve'