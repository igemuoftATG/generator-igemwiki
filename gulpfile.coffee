# Gulp and related plugins
gulp        = require "gulp"
handlebars  = require "gulp-compile-handlebars"
rename      = require "gulp-rename"
gutil       = require "gulp-util"
watch       = require 'gulp-watch'
combiner    = require "stream-combiner2"
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
    # Clear templates
    # templateDataStruct.templates = new Object()

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
        templateDataLive.links[link] = "http://#{year}.igem.org/Team:#{teamName}/#{linkVal}"
    # for template in Object.keys(templateData.templates)
    #     templateVal = templateData.templates[template]
    #     # templateDataDev.templates[template] = (fs.readFileSync("./build-dev/templates/#{template}.html")).toString()
    #     templateDataDev.templates[template] = templateVal
    #     templateDataLive.templates[template] = "{{#{teamName}/#{templateVal}}}"

    return {
        dev: templateDataDev
        live: templateDataLive
    }

paths =
    partials: './src/templates'

helpers = require "./helpers"
compileAllHbs = (templateData, dest) ->
    gutil.log templateData.templates.head

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

gulp.task 'serve', ['handlebars:dev'], ->
    browserSync.init
        server:
            baseDir: './build-dev'

    watch './src/**/*.hbs', ->
        fillTemplates()
        gulp.start('handlebars:dev')

gulp.task "default", ['serve']
