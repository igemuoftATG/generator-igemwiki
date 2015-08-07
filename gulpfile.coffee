# Gulp and related plugins
gulp = require "gulp"
handlebars = require "gulp-compile-handlebars"
rename = require "gulp-rename"
gutil = require "gulp-util"
combiner = require "stream-combiner2"

# Read some files into variables
fs = require "fs"
templateData = JSON.parse(fs.readFileSync('./src/template.json'))

buildTemplateStruct = (templateData) ->
    templateDataStruct = new Object()
    # Duplicate templateData
    for k in Object.keys(templateData)
        templateDataStruct[k] = templateData[k]
    # Clear links
    templateDataStruct.links = new Object()

    return templateDataStruct

templateDataDev = buildTemplateStruct(templateData)
templateDataLive = buildTemplateStruct(templateData)

teamName = templateData.teamName
year = templateData.year
for link in Object.keys(templateData.links)
    linkVal = templateData.links[link]
    templateDataDev.links[link] = "#{linkVal}.html"
    templateDataLive.links[link] = "http://#{year}.igem.org/Team:#{teamName}/#{linkVal}"

paths =
    partials: './src/partials'

helpers = require "./helpers"
compileHbs = (templateData, dest) ->
    hbsOptions =
        batch: [paths.partials],
        helpers: helpers

    return combiner(
        gulp.src("./src/hello.hbs"),
        handlebars(templateData, hbsOptions),
        rename("index.html"),
        gulp.dest(dest)
    )

gulp.task "handlebars:dev", ->
    return compileHbs(templateDataDev, "build-dev")

gulp.task "handlebars:live", ->
    return compileHbs(templateDataLive, "build-live")

gulp.task "handlebars", ["handlebars:dev", "handlebars:live"]

gulp.task "default", ["handlebars"]
