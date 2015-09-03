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
colors         = require 'colors'
globby         = require 'globby'
htmlparser     = require 'htmlparser2'
mainBowerFiles = require 'main-bower-files'
phantom        = require 'phantomjs'
readlineSync   = require 'readline-sync'
request        = require 'request'
combiner       = require 'stream-combiner2'
streamEqual    = require 'stream-equal'
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
    template     : './src/template.json'
    helpers      : 'helpers'
    images       : 'images.json'
    imagesFolder : './images'

dests =
    dev:
        folder : './build-dev'
        css    : './build-dev/css'
        js     : './build-dev/js'
    live:
        folder : './build-live'
        js     : './build-live/js'
        css    : './build-live/css'

globs =
    html      : "#{dests.dev.folder}/**/*.html"
    sass      : './src/sass/**/*.scss'
    md        : './src/markdown/**/*.md'
    css       : dests.dev.css
    libCoffee : './src/lib/**/*.coffee'
    libJS     : './src/lib/**/*.js'
    js        : './src/**/*.js'
    hbs       : './src/**/*.hbs'


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
        .src("#{dests.dev.js}/**/*.js")
        .pipe(concat('bundle.js'))
        .pipe(uglify().on('error', gutil.log))
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest(dests.live.js))


gulp.task 'minifyAndUglify', ['minify:css', 'uglify:js']


# **wiredep**
gulp.task 'wiredep', ['handlebars:dev'], ->
    return gulp
        .src(globs.html)
        .pipe(wiredep())
        .pipe(gulp.dest(dests.dev.folder))

# **build:dev**
gulp.task 'build:dev', ['wiredep', 'browserify']

# **build:live**
gulp.task 'build:live', ['handlebars:live', 'minifyAndUglify']

# **phantom**
gulp.task 'phantom', ->
    # see: phantom/screen.js
    templateData = fillTemplates().live

    sizes = ['mobile', 'phablet', 'tablet', 'desktop', 'desktophd']

    num = sizes.length * Object.keys(templateData.links).length

    gutil.log('Warning'.yellow + ", this will bang the revs on your CPUs. Just started #{num} phantom processes ;)")
    gutil.log('Use ' + 'gulp phantom:sync'.magenta + ' for slower, yet less CPU intensive usage.')

    for size in sizes
        for link of templateData.links
            page = templateData.links[link]

            if page is 'index'
                url = "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}"
            else
                url = "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}/#{page}"

            args = [
                "#{__dirname}/phantom/screen.js",
                url,
                "#{__dirname}/phantom/#{size}/#{page}",
                size
            ]

            process = cp.spawn(phantom.path, args)

            process.stdout.on 'data', (data) ->
                if data.toString().indexOf('Finished screening') isnt -1
                    gutil.log(data.toString().slice(0, data.toString().length - 1))

            process.stderr.on 'data', (data) ->
                gutil.log('stderr: ' + data)

            process.on 'close', (code) ->
                # gutil.log('Closed')


# **phantom:sync**
gulp.task 'phantom:sync', ->
    # see: phantom/screen.js
    templateData = fillTemplates().live

    sizes = ['mobile', 'phablet', 'tablet', 'desktop', 'desktophd']

    num = sizes.length * Object.keys(templateData.links).length

    gutil.log('Use ' + 'gulp phantom '.magenta + 'for faster, yet intensive processing.')
    gutil.log("You will have to cmd+c #{num} times to end this task.")

    for size in sizes
        for link of templateData.links
            page = templateData.links[link]

            if page is 'index'
                url = "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}"
            else
                url = "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}/#{page}"

            args = [
                "#{__dirname}/phantom/screen.js",
                url,
                "#{__dirname}/phantom/#{size}/#{page}",
                size
            ]

            process  = cp.spawnSync(phantom.path, args)
            gutil.log(process.stdout.toString().slice(0, process.stdout.toString().length - 1))

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
                        gutil.log('Successfully logged in'.green + ' as ' + "#{username}".magenta)
                        # Pass cookie jar into callback
                        cb(jar)
                    else
                        handleRequestError(err, httpResponse)
            else
                gutil.log('Incorrect username/password'.red)

# **logout**
logout = (jar) ->
    request {
        url: LOGOUT_URL
        jar: jar
    }, (err, httpResponse, body) ->
        if !err and httpResponse.statusCode is 200
            gutil.log('Successfully logged out'.green)
        else
            handleRequestError(err, httpResponse)

checkIfImageExists = (link, updateImageStores, cb) ->
    fs.readFile files.images, (err, data) ->
        if err
            gutil.log('No ' + 'images.json'.magenta + ' file')
            cb(false)
        else
            images = JSON.parse(data)

            fileStream = fs.createReadStream("images/#{link}")

            streamEqual request(images[link]), fileStream, (err, equal) ->
                if err?
                    gutil.log(err)
                else
                    if equal
                        imageStore = new Object()
                        imageStore[link] = images[link]
                        gutil.log("Skipping upload of ".yellow + "#{link}".magenta + " since live version is identical".yellow)
                        updateImageStores(imageStore)
                        cb(equal)
                    else
                        cb(equal)

# Calls cb(url, file, multiform, jar)
prepareUploadForm = (link, type, jar, cb, tryLogout, updateImageStores) ->
    templateData = JSON.parse(fs.readFileSync(files.template))
    year = templateData.year
    teamName = templateData.teamName

    if type is 'image'
        checkIfImageExists link, updateImageStores, (equal) ->
            if equal
                return;
            else
                BASE_URL = "http://#{year}.igem.org/Special:Upload"
                page = link
                url = BASE_URL
                editUrl = url
                visitEditPage(link, type, jar, cb, tryLogout, updateImageStores, editUrl, page, url)
    else
        if type is 'page'
            BASE_URL = "http://#{year}.igem.org/Team:#{teamName}"
            page = templateData.links[link]
        else if type is 'template'
            BASE_URL = "http://#{year}.igem.org/Template:#{teamName}"
            page = templateData.templates[link]
        else if type is 'stylesheet'
            BASE_URL = "http://#{year}.igem.org/Template:#{teamName}/css"
            page = link
        else if type is 'script'
            BASE_URL = "http://#{year}.igem.org/Template:#{teamName}/js"
            page = link

        if page is 'index' and type is 'page'
            url = BASE_URL
        else
            url = BASE_URL + '/' + page

        editUrl = url + '?action=edit'

        visitEditPage(link, type, jar, cb, tryLogout, updateImageStores, editUrl, page, url)

visitEditPage = (link, type, jar, cb, tryLogout, updateImageStores, editUrl, page, url) ->
    templateData = JSON.parse(fs.readFileSync(files.template))
    year = templateData.year
    teamName = templateData.teamName

    request {
        url : editUrl
        jar : jar
    }, (err, httpResponse, body) ->
        if !err and httpResponse.statusCode is 200
            if type isnt 'image'
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
            else
                multiform = {
                    wpUploadFile         : ''
                    wpDestFile           : ''
                    wpUploadDescription  : ''
                    wpLicense            : ''
                    wpEditToken          : ''
                    title                : ''
                    wpDestFileWarningAck : ''
                    wpUpload             : ''
                    wpIgnoreWarning      : '1'
                    # wpWatchthis          : '1'
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

            if type is 'page'
                file = "#{dests.live.folder}/#{page}.html"
            else if type is 'template'
                file = "#{dests.live.folder}/templates/#{page}.html"
            else if type is 'stylesheet'
                file = "#{dests.live.folder}/css/#{page}"
            else if type is 'script'
                file = "#{dests.live.folder}/js/#{page}"
            else if type is 'image'
                file = "./images/#{page}"

            if type isnt 'image'
                multiform['wpTextbox1'] = fs.readFileSync(file, 'utf8')
            else
                multiform['wpUploadFile'] = fs.createReadStream(file)
                multiform['wpDestFile'] = "#{teamName}_#{year}_#{page}"

            cb(url, file, page, type, multiform, jar, tryLogout, updateImageStores)
        else
            handleRequestError(err, httpResponse)

colourify = (file, url, multiform, type) ->
    if type is 'image'
        year = JSON.parse(fs.readFileSync(files.template)).year
        return "Uploaded #{file} → http://#{year}.igem.org/File:#{multiform['wpDestFile']}".yellow
    else if path.extname(file) is '.html' and url.indexOf('Template') > 0
        return "Uploaded #{file} → #{url}".cyan
    else if path.extname(file) is '.html'
        return "Uploaded #{file} → #{url}".grey
    else if path.extname(file) is '.css'
        return "Uploaded #{file} → #{url}".magenta
    else if path.extname(file) is '.js'
        return "Uploaded #{file} → #{url}".blue
    else
        return "Uploaded #{file} → #{url}"

# **postEdit**
postEdit = (url, file, page, type, multiform, jar, tryLogout, updateImageStores) ->

    if type isnt 'image'
        postUrl = url + '?action=submit'
    else
        postUrl = url

    request {
        url      : postUrl
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
                    if type is 'image'
                        currentHref = new String()
                        finalHref   = new String()

                        parser = new htmlparser.Parser {
                            onopentag: (name, attr) ->
                                if name is 'a'
                                    currentHref = attr.href
                            ontext: (text) ->
                                if text is 'Full resolution' or text is multiform['wpDestFile']
                                    finalHref = currentHref
                        }, {decodeEntites: true}

                        parser.write(body)
                        parser.end()

                        templateData = JSON.parse(fs.readFileSync(files.template))
                        imageStore = new Object()
                        imageStore["#{page}"] = "http://#{templateData.year}.igem.org#{finalHref}"

                        fs.writeFileSync("responses/#{page}.html", body)
                        gutil.log(colourify(file, url, multiform, type))
                        updateImageStores(imageStore)
                        tryLogout()
                    else
                        fs.writeFileSync("responses/#{page}.html", body)
                        gutil.log(colourify(file, url, multiform, type))
                        tryLogout()
                else
                    handleRequestError(err, httpResponse)
        else
            handleRequestError(err, httpResponse)

upload = (link, type, jar, tryLogout, updateImageStores) ->
    if link isnt '.DS_Store'
        prepareUploadForm(link, type, jar, postEdit, tryLogout, updateImageStores)

# **push**
gulp.task 'push', ->
    login (jar) ->
        templateData = JSON.parse(fs.readFileSync(files.template))
        stylesheets  = fs.readdirSync(dests.live.css)
        scripts      = fs.readdirSync(dests.live.js)
        images       = fs.readdirSync('images')

        num = 0
        tryLogout = ->
            num += 1
            total = Object.keys(templateData.links).length +
                Object.keys(templateData.templates).length +
                stylesheets.length +
                scripts.length +
                images.length

            if num is total
                logout(jar)

        imageStores = new Object()
        imageStoresFile = files.images
        updateImageStores = (imageStore) ->
            key = Object.keys(imageStore)[0]
            imageStores[key] = imageStore[key]

            if '.DS_Store' in fs.readdirSync(files.imagesFolder)
                len = images.length - 1
            else
                len = images.length

            if Object.keys(imageStores).length is len
                fs.writeFileSync(imageStoresFile, JSON.stringify(imageStores))
                gutil.log('Full resolution links of images stored in'.green, "#{imageStoresFile}".magenta)

        for link of templateData.links
            upload(link, 'page', jar, tryLogout)
        for template of templateData.templates
            upload(template, 'template', jar, tryLogout)
        for stylesheet in stylesheets
            upload(stylesheet, 'stylesheet', jar, tryLogout)
        for script in scripts
            upload(script, 'script', jar, tryLogout)
        for image in images
            upload(image, 'image', jar, tryLogout, updateImageStores)

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
                '/images'           : './images'

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
