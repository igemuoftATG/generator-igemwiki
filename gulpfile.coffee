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
htmlparser     = require 'htmlparser2'
mainBowerFiles = require 'main-bower-files'
phantom        = require 'phantomjs'
readlineSync   = require 'readline-sync'
request        = require 'request'
combiner       = require 'stream-combiner2'
source         = require 'vinyl-source-stream'
browserSync    = require('browser-sync').create()
wiredep        = require('wiredep').stream

# NodeJS internal modules
cp   = require 'child_process'
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

# **phantom**
gulp.task 'phantom', ->
    templateData = JSON.parse(fs.readFileSync(files.template))
    year = templateData.year
    teamName = templateData.teamName

    args = [
        "#{__dirname}/phantom/screen.js",
        # "http://#{year}.igem.org/Team:#{teamName}?action=edit",
        'http://igem.org/Login'
        "phantom/imgs/#{teamName}"
    ]
    cp.execFile phantom.path, args, (err, stdout, stderr) ->
        if err
            gutil.log(err)
            return

        gutil.log(stderr)
        gutil.log(stdout)
        gutil.log('done')


handleRequestError = (err, httpResponse) ->
    gutil.log('err: ', err)
    gutil.log('status code: ', httpResponse.statusCode)

LOGIN_URL = 'http://igem.org/Login'
LOGOUT_URL = 'http://igem.org/cgi/Logout.cgi'
# Login and call the callback with the cookie jar
login = (cb) ->
    username = readlineSync.question('Username: ')
    password = readlineSync.question('Password: ', {hideEchoBack: true})
    jar = request.jar()

    request {
        url: LOGIN_URL,
        method: 'POST'
        form: {
            id              : '0'
            new_user_center : ''
            new_user_right  : ''
            hidden_new_user : ''
            return_to       : ''
            username        : username
            password        : password
            Login           : 'Log+in'
            search_text     : ''
        },
        jar: jar
    }, (err, httpResponse, body) ->
            if !err and httpResponse.statusCode is 302
                # Follow redirects to complete login
                request {
                    url: httpResponse.headers.location
                    jar: jar
                }, (err, httpResponse, body) ->
                    if !err and httpResponse.statusCode is 200
                        gutil.log("Successfully logged in as #{username}")
                        # Pass cookie jar into callback
                        cb(jar)
                    else
                        handleRequestError(err, httpResponse)
            else
                gutil.log('Incorrect username/password')

# **logout**
logout = (jar) ->
    request {
        url: LOGOUT_URL
        jar: jar
    }, (err, httpResponse, body) ->
        if !err and httpResponse.statusCode is 200
            gutil.log('Successfully logged out')
        else
            handleRequestError(err, httpResponse)

# Calls cb(url, file, multiform, jar)
prepareUploadForm = (link, jar, cb) ->
    templateData = JSON.parse(fs.readFileSync(files.template))
    year = templateData.year
    teamName = templateData.teamName
    BASE_URL = "http://#{year}.igem.org/Team:#{teamName}"

    page = templateData.links[link]
    if page is 'index'
        url = BASE_URL
    else
        url = BASE_URL + '/' + page

    request {
        url : url + '?action=edit'
        jar : jar
    }, (err, httpResponse, body) ->
        if !err and httpResponse.statusCode is 200
            multiform = {
                wpSection     : ''
                wpStarttime   : ''
                wpEdittime    : ''
                wpScrolltop   : ''
                wpAutoSummary : ''
                oldid         : ''
                wpTextbox1    : ''
                wpSummary     : ''
                wpSave        : ''
                wpEditToken   : ''
            }

            parser = new htmlparser.Parser {
                onopentag: (name, attr) ->
                    if attr.name? and multiform[attr.name]?
                        if !attr.value
                            multiform[attr.name] = ''
                        else
                            multiform[attr.name] = attr.value
            }, {decodeEntites: true}

            parser.write(body)
            parser.end();

            file = "#{dests.live.folder}/#{page}.html"
            multiform['wpTextbox1'] = fs.readFileSync(file, 'utf8')

            gutil.log("#{file} -> ", url)

            cb(url, file, multiform, jar)

# **postEdit**
postEdit = (url, file, multiform, jar) ->
    request {
        url: url + '?action=submit'
        method: 'POST'
        formData: multiform
        jar: jar
    }, (err, httpResponse, body) ->
        if !err and httpResponse.statusCode is 302
            # Follow redirect to new page
            request {
                url: httpResponse.headers.location
                jar: jar
            }, (err, httpResponse, body) ->
                if !err and httpResponse.statusCode is 200
                    gutil.log("Successfully uploaded #{file} -> #{url}")
                    fs.writeFileSync("response/#{file}.html", body)
                else
                    handleRequestError(err, httpResponse)
        else
            handleRequestError(err, httpResponse)

upload = (link, jar) ->
    prepareUploadForm(link, jar, postEdit)

# **push**
gulp.task 'push', ->
    login (jar) ->
        templateData = JSON.parse(fs.readFileSync(files.template))

        for link of templateData.links
            prepareUploadForm link, jar, (multiform) ->
                gutil.log('wheeee')
                # gutil.log(multiform)

        request {
            url: 'http://2015.igem.org/Team:Toronto/Team?action=edit'
            jar: jar
        }, (err, httpResponse, body) ->
            if !err and httpResponse.statusCode is 200
                multiform = {
                    wpSection     : ''
                    wpStarttime   : ''
                    wpEdittime    : ''
                    wpScrolltop   : ''
                    wpAutoSummary : ''
                    oldid         : ''
                    wpTextbox1    : ''
                    wpSummary     : ''
                    wpSave        : ''
                    wpEditToken   : ''
                }

                parser = new htmlparser.Parser {
                    onopentag: (name, attr) ->
                        if attr.name? and multiform[attr.name]?
                            if !attr.value
                                multiform[attr.name] = ''
                            else
                                multiform[attr.name] = attr.value
                }, {decodeEntites: true}

                parser.write(body)
                parser.end();

                multiform['wpTextbox1'] = fs.readFileSync('build-live/Team.html', 'utf8')

                request {
                    url      : 'http://2015.igem.org/Team:Toronto/Team?action=submit'
                    method   : 'POST'
                    formData : multiform
                    jar      : jar
                }, (err, httpResponse, body) ->
                    if !err and httpResponse.statusCode is 302
                        # Follow redirect to new page
                        request {
                            url: httpResponse.headers.location
                            jar: jar
                        }, (err, httpResponse, body) ->
                            if !err and httpResponse.statusCode is 200
                                gutil.log('Successfully uploaded X')
                                fs.writeFileSync('response.html', body)
                            else
                                handleRequestError(err, httpResponse)
                    else
                        handleRequestError(err, httpResponse)
            else
                handleRequestError(err, httpResponse)

            logout(jar)

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
