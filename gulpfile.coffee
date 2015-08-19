# Gulp and related plugins
gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
handlebars = require 'gulp-compile-handlebars'
concat     = require 'gulp-concat'
cssmin     = require 'gulp-cssmin'
rename     = require 'gulp-rename'
sass       = require 'gulp-sass'
sourcemaps = require 'gulp-sourcemaps'
uglify     = require 'gulp-uglify'
gutil      = require 'gulp-util'
watch      = require 'gulp-watch'

# NodeJS modules
browserify     = require 'browserify'
buffer         = require 'vinyl-buffer'
coffeeify      = require 'coffeeify'
globby         = require 'globby'
mainBowerFiles = require 'main-bower-files'
combiner       = require 'stream-combiner2'
source         = require 'vinyl-source-stream'
browserSync    = require('browser-sync').create()
wiredep        = require('wiredep').stream

# NodeJS internal modules
fs   = require 'fs'
path = require 'path'

paths =
    partials: './src/templates'

files =
    template : './src/template.json'
    helpers  : 'helpers'

globs =
    sass      : './src/styles/sass/*.scss'
    md        : './src/markdown/**/*.md'
    css       : './src/styles/**/*.css'
    libCoffee : './src/lib/**/*.coffee'
    libJS     : './src/lib/**/*.js'
    js        : './src/**/*.js'
    hbs       : './src/**/*.hbs'

dests =
    dev:
        folder : './build-dev'
        css    : './src/styles'
        js     : './build-dev/js'
    live:
        folder : './build-live'
        js     : './build-live/js'
        css    : './build-live/css'

# The data for our handlebars templates
# templateData = JSON.parse(fs.readFileSync(files.template))

# **buildTemplateStruct**
buildTemplateStruct = (templateData, mode) ->
    templateDataStruct = new Object()
    # Hard-copy `templateData`
    for k in Object.keys(templateData)
        templateDataStruct[k] = templateData[k]
    # Add `mode`
    templateDataStruct.mode = mode

    return templateDataStruct

# **fillTemplates**
fillTemplates = ->
    templateData = JSON.parse(fs.readFileSync(files.template))
    # Return `dev` and `live` template datas
    return {
        dev: buildTemplateStruct(templateData, 'dev')
        live: buildTemplateStruct(templateData, 'live')
    }

# **compileAllHbs**
compileAllHbs = (templateData, dest) ->
    # see: `helpers.coffee`
    Helpers = require "./helpers"
    # Pass in the *actual* `Handlebars` module and `templateData`.
    # Otherwise, helper functions are not found.
    helpers = new Helpers(handlebars.Handlebars, templateData)

    # Delete `Helpers` from require cache so that next `require` gets new version
    for key in Object.keys(require.cache)
        if key.indexOf("#{files.helpers}.js") isnt -1 and key.indexOf('node_modules') is -1
            delete require.cache[key]

    # Handlebars options, `batch` is where partials (templates in wiki case) are stored
    hbsOptions =
        batch: [paths.partials],
        helpers: helpers

    # Return a `combiner` stream. Series of pipes will not work here.
    return combiner(
        gulp.src(globs.hbs),
        handlebars(templateData, hbsOptions),
        rename((path) ->
            path.extname = ".html"
        ),
        gulp.dest(dest)
    ).on 'end', ->
        # Reload browser on finish
        browserSync.reload()

# **coffeescript:helpers**
gulp.task 'coffeescript:helpers', ->
    return gulp
        .src("#{files.helpers}.coffee")
        .pipe(coffee().on('error', gutil.log))
        .pipe(gulp.dest('.'))

# **handlebars:dev**
gulp.task "handlebars:dev", ->
    return compileAllHbs(fillTemplates().dev, dests.dev.folder)

# **handlebars:live**
gulp.task "handlebars:live", ->
    return compileAllHbs(fillTemplates().live, dests.live.folder)

# Compile `.scss` into `.css`
gulp.task 'sass', ->
    return gulp
        .src(globs.sass)
        .pipe(sass({
            includePaths: ['./bower_components/compass-mixins/lib']
        }).on('error', sass.logError))
        .pipe(gulp.dest(dests.dev.css))
        .pipe(browserSync.stream())

# Compile `.coffee` into `.js`; browserify
gulp.task 'browserify', ->
    globby [globs.libCoffee, globs.libJS], (err,entries) ->
        if err
            gutil.log()
            return

        b = browserify({
            entries: entries
            extensions: ['.coffee', '.js']
            debug: true
            transform: [coffeeify]
        })

        combined = combiner.obj([
            b.bundle(),
            source('bundle.js'),
            buffer(),
            sourcemaps.init({loadMaps: true}),
            sourcemaps.write('./maps'),
            gulp.dest(dests.dev.js)
        ])

        combined.on('error', gutil.log)

        return combined

# **bower:js**
gulp.task 'bower:js', ->
    return gulp
        .src(mainBowerFiles('**/*.js'), { base: './bower_components'})
        .pipe(concat('vendor.js'))
        .pipe(uglify().on('error', gutil.log))
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest(dests.live.js))

# **bower:css**
gulp.task 'bower:css', ->
    return gulp
        .src(mainBowerFiles('**/*.css'), { base: './bower_components'})
        .pipe(concat('vendor.css'))
        .pipe(cssmin())
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest(dests.live.css))

# **bower**
gulp.task 'bower', ['bower:js', 'bower:css']

gulp.task 'minify:css', ['bower'], ->
    return gulp
        .src(globs.css)
        .pipe(concat('styles.css'))
        .pipe(cssmin())
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest(dests.live.css))

gulp.task 'uglify:js', ['bower'], ->
    return gulp
        .src(globs.js)
        .pipe(concat('bundle.js'))
        .pipe(uglify().on('error', gutil.log))
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest(dests.live.js))


gulp.task 'minifyAndUglify', ['minify:css', 'uglify:js']

# **wiredep**
gulp.task 'wiredep', ['handlebars:dev'], ->
    return gulp
        .src("#{dests.dev.folder}/index.html")
        .pipe(wiredep())
        .pipe(gulp.dest(dests.dev.folder))

# **build:dev**
gulp.task 'build:dev', ['wiredep', 'browserify']

# **build:live**
gulp.task 'build:live', ['handlebars:live', 'minifyAndUglify']

# **serve**
gulp.task 'serve', ['sass', 'build:dev'], ->
    browserSync.init
        server:
            baseDir: dests.dev.folder
            routes:
                '/styles'           : dests.dev.css
                '/bower_components' : './bower_components'
                '/js'               : dests.dev.js
                '/preamble'         : './src/preamble'

    watch [globs.hbs, globs.js, globs.md, files.template], ->
        fillTemplates()
        gulp.start('build:dev')

    watch globs.sass, ->
        gulp.start('sass')

    watch [globs.libCoffee, globs.libJS], ->
        gulp.start('browserify')

    watch "#{files.helpers}.coffee", ->
        gulp.start('coffeescript:helpers')

# What happens when you run `gulp`
gulp.task "default", ['serve']
