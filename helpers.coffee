# NodeJS core modules
fs   = require 'fs'
path = require 'path'

# NodeJS modules
gutil       = require 'gulp-util'
marked      = require 'marked'
highlighter = require 'highlight.js'

hbs = new Object()
templateData = new Object()

class Helpers
    constructor: (handlebars, tplateData) ->
        hbs = handlebars
        templateData = tplateData

        return {
            template   : @template
            capitals   : @capitals
            bodyInsert : @bodyInsert
            link       : @link
            cssInject  : @cssInject
            jsInject   : @jsInject
            markdown   : @markdown
            image      : @image
        }

    capitals: (str) ->
        return str.toUpperCase()

    bodyInsert: (mode) ->
        if mode isnt 'live'
            content = '<body></body>'
        else
            content = ''

        return new hbs.SafeString(content)

    jsInject: (mode) ->
        content = new String()

        if mode is 'live'
            dir = './build-live/js'
        else
            dir = './build-dev/js'

        scripts = fs.readdirSync(dir)

        if mode isnt 'live'
            content += "<!-- bower:js -->\n\t<!-- endbower -->\n\t"

        for script in scripts
            if path.extname(script) is '.js'
                if mode is 'live' and script isnt 'vendor.min.js'
                    content += "<script src=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/js/#{script}?action=raw&type=text/js\"></script>\n\t"
                else
                    if script isnt 'vendor.min.js'
                        content += "<script src=\"js/#{script}\"></script>\n\t"

        # Append 'vendor.min.js' after all other scripts for live build
        for script in scripts
            if script is 'vendor.min.js'
                content = "<script src=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/js/#{script}?action=raw&type=text/js\"></script>\n\t" + content

        return new hbs.SafeString(content)

    cssInject: (mode) ->
        content = new String()
        if mode is 'live'
            dir = './build-live/css'
        else
            dir = './src/styles'

        styles = fs.readdirSync(dir)

        if mode isnt 'live'
            content += "<!-- bower:css -->\n\t<!-- endbower -->\n\t"

        for stylesheet in styles
            if path.extname(stylesheet) is '.css'
                if mode is 'live' and stylesheet isnt 'vendor.min.css'
                    content += "<link rel=\"stylesheet\" href=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/css/#{stylesheet}?action=raw&ctype=text/css\" type=\"text/css\" />\n\t"
                else if stylesheet isnt 'vendor.min.css'
                    content += "<link rel=\"stylesheet\" href=\"styles/#{stylesheet}\" type=\"text/css\" />\n\t"

        for stylesheet in styles
            if stylesheet is 'vendor.min.css'
                content = "<link rel=\"stylesheet\" href=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/css/#{stylesheet}?action=raw&ctype=text/css\" type=\"text/css\" />\n\t" + content

        return new hbs.SafeString(content)

    # img: String of image filename in ./images/filename
    # format: use directlink for normal img tag to full resolution of file
    # use file for inline image using wiki code. this requires breaking and opening html
    # use media for an anchor that points to the full resolution of file
    # see images.json, and 'hardcode' your own markup, the links there should not change
    # note: images.json requires a successful `gulp push` to become populated with new images
    # for instance, you will probably need to hardcode image links into your markdown files
    # ATM, I'm not running handlebars compilation on the html compiled from markdown
    image: (img, format, mode) ->
        if mode is 'live'
            if format is 'directlink'
                imageStores = JSON.parse(fs.readFileSync('images.json'))
                content = "<img src=\"#{imageStores[img]}\" />"
            else
                if format is 'file'
                    fmt = 'File'
                else if format is 'media'
                    fmt = 'Media'

                content = "</html> [[#{fmt}:#{templateData.teamName}_#{templateData.year}_#{img}]] <html>"
        else
            content = "<img src=\"images/#{img}\" />"

        return new hbs.SafeString(content)

    link: (linkName, mode) ->
        if mode is 'live'
            if linkName is 'index'
                return "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}"
            else
                return "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}/#{linkName}"
        else
            if linkName is 'index'
                return 'index.html'
            else
                return "#{linkName}.html"

    template: (templateName, mode) ->
        template = hbs.compile(fs.readFileSync("#{__dirname}/src/templates/#{templateName}.hbs", 'utf8'))
        if mode is 'live'
            # Don't add preamble to live build
            if templateName is 'preamble'
                return new hbs.SafeString('')

            return new hbs.SafeString("{{#{templateData.teamName}/#{templateName}}}")
        else
            # Assume 'dev' mode if undefined
            # For some reason, get an extra call here with mode undefined when in dev mode
            return new hbs.SafeString(template(templateData))

    markdown: (file) ->
        marked.setOptions({
            highlight: (code) ->
                 return highlighter.highlightAuto(code).value
        })

        return new hbs.SafeString(marked(fs.readFileSync("#{__dirname}/src/markdown/#{file}.md", 'utf8').toString()))


module.exports = Helpers
