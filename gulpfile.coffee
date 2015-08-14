# Gulp and related plugins
gulp        = require "gulp"
handlebars  = require "gulp-compile-handlebars"
rename      = require "gulp-rename"
gutil       = require "gulp-util"
watch       = require 'gulp-watch'
combiner    = require "stream-combiner2"
sass        = require 'gulp-sass'
browserSync = require('browser-sync').create()

# NodeJS modules
fs = require "fs"
path = require "path"

# The data for our handlebars templates
templateData = JSON.parse(fs.readFileSync('./src/template.json'))

buildTemplateStruct = (templateData) ->
    templateDataStruct = new Object()
    # Duplicate templateData
    for k in Object.keys(templateData)
        templateDataStruct[k] = templateData[k]
    # Clear links
    templateDataStruct.links = new Object()

    return templateDataStruct

fillTemplates = ->
    templateDataDev = buildTemplateStruct(templateData)
    templateDataDev.mode = 'dev'
    templateDataLive = buildTemplateStruct(templateData)
    templateDataLive.mode = 'live'

    teamName = templateData.teamName
    year = templateData.year
    for link in Object.keys(templateData.links)
        linkVal = templateData.links[link]
        templateDataDev.links[link] = "#{linkVal}.html"
        if linkVal is "index"
            templateDataLive.links[link] = "http://#{year}.igem.org/Team:#{teamName}"
        else
            templateDataLive.links[link] = "http://#{year}.igem.org/Team:#{teamName}/#{linkVal}"

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

Helpers = require "./helpers"
helpers = new Helpers(handlebars.Handlebars, templateData)
compileAllHbs = (templateData, dest) ->
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

gulp.task 'serve', ['sass', 'handlebars:dev'], ->
    browserSync.init
        server:
            baseDir: './build-dev'
            routes:
                '/styles' : './src/styles'

    watch './src/**/*.hbs', ->
        fillTemplates()
        gulp.start('handlebars:dev')

    watch globs.sass, ->
        gulp.start('sass')

gulp.task "default", ['serve']
