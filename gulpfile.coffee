# Gulp and related plugins
gulp = require "gulp"
handlebars = require "gulp-compile-handlebars"
rename = require "gulp-rename"
gutil = require "gulp-util"

# Read some files into variables
fs = require "fs"
templateData = JSON.parse(fs.readFileSync('./src/templates/template.json'))

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

year = "2015"
teamName = templateData.teamName

for link in Object.keys(templateData.links)
    linkVal = templateData.links[link]
    templateDataDev.links[link] = "#{linkVal}.html"
    templateDataLive.links[link] = "http://#{year}.igem.org/Team:#{teamName}/#{linkVal}"


paths =
    partials: './src/partials'

hbsOptions =
    batch: [paths.partials],
    helpers:
        capitals : (str) ->
            return str.toUpperCase();

# compileHbs = (templateData) ->
#     gutil.log(templateData)
#     return gulp.src("./src/hello.bhs")
#         .pipe(handlebars(templateData, hbsOptions))
#         .pipe(rename("index.html"))
#         .pipe(gulp.dest("build-dev"))
#
# gulp.task "handlebars:dev", ->
#     return compileHbs(templateDataDev)

gulp.task "handlebars:dev", ->
    return gulp.src "src/hello.hbs"
        .pipe(handlebars(templateDataDev, hbsOptions))
        .pipe(rename("index.html"))
        .pipe(gulp.dest("build-dev"))

gulp.task "handlebars:live", ->
    return gulp.src "src/hello.hbs"
        .pipe(handlebars(templateDataLive, hbsOptions))
        .pipe(rename("index.html"))
        .pipe(gulp.dest("build-live"))

gulp.task "handlebars", ["handlebars:dev", "handlebars:live"]

gulp.task "default", ["handlebars"]
