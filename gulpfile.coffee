gulp = require "gulp"
handlebars = require "gulp-compile-handlebars"
rename = require "gulp-rename"
fs = require "fs"

paths =
    partials: './src/partials'

hbsOptions =
    batch: [paths.partials],
    helpers:
        capitals : (str) ->
            return str.toUpperCase();


templateDataDev = JSON.parse(fs.readFileSync('./src/templates/template-dev.json'))

gulp.task "handlebars", ->
    return gulp.src "src/hello.hbs"
        .pipe(handlebars(templateDataDev, hbsOptions))
        .pipe(rename("index.html"))
        .pipe(gulp.dest("build-dev"))

gulp.task "default", ["handlebars"]
