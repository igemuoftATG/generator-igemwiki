# Gulp and related plugins
gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
handlebars = require 'gulp-compile-handlebars'
concat     = require 'gulp-concat'
cssmin     = require 'gulp-cssmin'
rename     = require 'gulp-rename'
sass       = require 'gulp-sass'
uglify     = require 'gulp-uglify'
gutil      = require 'gulp-util'
watch      = require 'gulp-watch'

# NodeJS modules
mainBowerFiles = require 'main-bower-files'
combiner       = require 'stream-combiner2'
browserSync    = require('browser-sync').create()
wiredep        = require('wiredep').stream

# NodeJS Internal Modules
fs   = require "fs"
path = require "path"

# The data for our handlebars templates
templateData = JSON.parse(fs.readFileSync('./src/template.json'))

buildTemplateStruct = (templateData) ->
    templateDataStruct = new Object()
    # Duplicate templateData
    for k in Object.keys(templateData)
        templateDataStruct[k] = templateData[k]

    return templateDataStruct

fillTemplates = ->
    templateDataDev = buildTemplateStruct(templateData)
    templateDataDev.mode = 'dev'
    templateDataLive = buildTemplateStruct(templateData)
    templateDataLive.mode = 'live'

    return {
        dev: templateDataDev
        live: templateDataLive
    }

paths =
    partials: './src/templates'

globs =
    sass: './src/styles/sass/*.scss'

dests =
    css: './src/styles'


compileAllHbs = (templateData, dest) ->
    Helpers = require "./helpers"
    helpers = new Helpers(handlebars.Handlebars, templateData)

    # Delete Helpers from require cache so that next require gets new version
    for key in Object.keys(require.cache)
        if key.indexOf('helpers.js') isnt -1 and key.indexOf('node_modules') is -1
            delete require.cache[key]

    hbsOptions =
        batch: [paths.partials],
        helpers: helpers

    return combiner(
        gulp.src("./src/**/*.hbs"),
        handlebars(templateData, hbsOptions),
        rename((path) ->
            path.extname = ".html"
        ),
        gulp.dest(dest)
    ).on 'end', ->
        browserSync.reload()

gulp.task 'coffeescript:helpers', ->
    return gulp
        .src('./helpers.coffee')
        .pipe(coffee().on('error', gutil.log))
        .pipe(gulp.dest('.'))

gulp.task 'helpers', ['coffeescript:helpers']

gulp.task "handlebars:dev", ->
    return compileAllHbs(fillTemplates().dev, "build-dev")

gulp.task "handlebars:live", ->
    return compileAllHbs(fillTemplates().live, "build-live")

# Compile `.scss` into `.css`
gulp.task 'sass', ->
    return gulp
        .src(globs.sass)
        .pipe(sass({
            includePaths: ['./bower_components/compass-mixins/lib']
        }).on('error', sass.logError))
        .pipe(gulp.dest(dests.css))
        .pipe(browserSync.stream())

gulp.task 'bower:js', ->
    return gulp
        .src(mainBowerFiles('**/*.js'), { base: './bower_components'})
        .pipe(concat('vendor.js'))
        .pipe(uglify().on('error', gutil.log))
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest('./src/js'))

gulp.task 'bower:css', ->
    return gulp
        .src(mainBowerFiles('**/*.css'), { base: './bower_components'})
        .pipe(concat('vendor.css'))
        .pipe(cssmin())
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest('./src/styles'))

gulp.task 'bower', ['bower:js', 'bower:css']

gulp.task 'wiredep', ['handlebars:dev'], ->
    return gulp
        .src('./build-dev/index.html')
        .pipe(wiredep())
        .pipe(gulp.dest('./build-dev'))

gulp.task 'build:dev', ['wiredep']

gulp.task 'build:live', ['handlebars:live', 'bower']

gulp.task 'serve', ['sass', 'build:dev'], ->
    browserSync.init
        server:
            baseDir: './build-dev'
            routes:
                '/styles'           : './src/styles'
                '/bower_components' : './bower_components'
                '/js'               : './src/js'
                '/preamble'         : './src/preamble'

    watch './src/**/*.hbs', ->
        fillTemplates()
        gulp.start('build:dev')

    watch globs.sass, ->
        gulp.start('sass')

    watch './helpers.coffee', ->
        gulp.start('helpers')

gulp.task "default", ['serve']
