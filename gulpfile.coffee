# Gulp and related plugins
gulp = require "gulp"
handlebars = require "gulp-compile-handlebars"
rename = require "gulp-rename"
gutil = require "gulp-util"
combiner = require "stream-combiner2"

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
    templateDataStruct.templates = new Object()

    return templateDataStruct

templateDataDev = buildTemplateStruct(templateData)
templateDataLive = buildTemplateStruct(templateData)

teamName = templateData.teamName
year = templateData.year
for link in Object.keys(templateData.links)
    linkVal = templateData.links[link]
    templateDataDev.links[link] = "#{linkVal}.html"
    templateDataLive.links[link] = "http://#{year}.igem.org/Team:#{teamName}/#{linkVal}"
for template in Object.keys(templateData.templates)
    templateVal = templateData.templates[template]
    templateDataDev.templates[template] = fs.readFileSync("./build-dev/templates/#{template}.html")
    templateDataLive.templates[template] = "{{#{templateVal}}}"


paths =
    partials: './src/templates'

helpers = require "./helpers"
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
    )

gulp.task "handlebars:dev", ->
    return compileAllHbs(templateDataDev, "build-dev")

gulp.task "handlebars:live", ->
    return compileAllHbs(templateDataLive, "build-live")

gulp.task "handlebars", ["handlebars:dev", "handlebars:live"]

gulp.task "default", ["handlebars"]
