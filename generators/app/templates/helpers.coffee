# NodeJS core modules
fs   = require 'fs'
path = require 'path'

# NodeJS modules
gutil       = require 'gulp-util'
marked      = require 'marked'
toc         = require 'markdown-toc'
highlighter = require 'highlight.js'
wiredep     = require('wiredep')()

hbs = new Object()
templateData = new Object()

class Helpers
    constructor: (handlebars, tplateData) ->
        hbs = handlebars
        templateData = tplateData

        return {
            template     : @template
            capitals     : @capitals
            bodyInsert   : @bodyInsert
            link         : link
            cssInject    : @cssInject
            jsInject     : @jsInject
            markdown     : @markdown
            markdownHere : @markdownHere
            image        : @image
            navigation   : @navigationWrapper
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
            content += "<!-- bower:js -->\n\t"
            for script in wiredep.js
                script = script.slice(script.indexOf('bower_components'))

                content += "<script src=\"#{script}\"></script>\n\t"
            content += "<!-- endbower -->\n\t"

        for script in scripts
            # if path.extname(script) is '.js'
            if mode is 'live' and script isnt 'vendor_min_js'
                content += "<script src=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/js/#{script}?action=raw&ctype=text/javascript\"></script>\n\t"
            else
                if script isnt 'vendor_min_js'
                    content += "<script src=\"js/#{script}\"></script>\n\t"

        # Append 'vendor.min.js' after all other scripts for live build
        for script in scripts
            if script is 'vendor_min_js'
                content = "<script src=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/js/#{script}?action=raw&ctype=text/javascript\"></script>\n\t" + content

        return new hbs.SafeString(content)

    cssInject: (mode) ->
        content = new String()
        if mode is 'live'
            dir = './build-live/css'
        else
            dir = './build-dev/css'

        styles = fs.readdirSync(dir)

        if mode isnt 'live'
            content += "<!-- bower:css -->\n\t"
            for stylesheet in wiredep.css

                stylesheet = stylesheet.slice(stylesheet.indexOf('bower_components'))

                content += "<link rel=\"stylesheet\" href=\"#{stylesheet}\" type=\"text/css\" />\n\t"
            content += "<!-- endbower -->\n\t"

        if mode is 'live'
            content += '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">\n\t'

        for stylesheet in styles
            # if path.extname(stylesheet) is '.css'
            # if mode is 'live' and stylesheet isnt 'vendor.min.css'
            if mode is 'live' and stylesheet isnt 'vendor_min_css'
                content += "<link rel=\"stylesheet\" href=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/css/#{stylesheet}?action=raw&ctype=text/css\" type=\"text/css\" />\n\t"
            # else if stylesheet isnt 'vendor.min.css'
            else if stylesheet isnt 'vendor_min_css'
                content += "<link rel=\"stylesheet\" href=\"styles/#{stylesheet}\" type=\"text/css\" />\n\t"

        for stylesheet in styles
            # if stylesheet is 'vendor.min.css'
            if stylesheet is 'vendor_min_css'
                content = "<link rel=\"stylesheet\" href=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/css/#{stylesheet}?action=raw&ctype=text/css\" type=\"text/css\" />\n\t" + content

        return new hbs.SafeString(content)

    # img: String of image filename in ./images/filename
    # format: use directlink for normal img tag to full resolution of file
    # use file for inline image using wiki code. this requires breaking and opening html
    # use media for an anchor that points to the full resolution of file
    # see images.json, and 'hardcode' your own markup, the links there should not change
    # note: images.json requires a successful `gulp push` to become populated with new images
    image: (img, format, mode) ->
        if mode is 'live'
            if format is 'directlink'
                if fs.readdirSync(__dirname).indexOf('images.json') isnt -1
                    imageStores = JSON.parse(fs.readFileSync('images.json'))
                    content = imageStores[img]
                else
                    content = ''
            else
                if format is 'file'
                    fmt = 'File'
                else if format is 'media'
                    fmt = 'Media'

                # content = "</html> [[#{fmt}:#{templateData.teamName}_#{templateData.year}_#{img}]] <html>"
                # Quick n' dirty fix
                content = "</html> [[File:#{templateData.teamName}_#{templateData.year}_#{img}]] <html>"
        else
            if format isnt 'directlink'
                content = "<img src=\"images/#{img}\" />"
            else
                content = "images/#{img}"

        return new hbs.SafeString(content)

    link = (linkName, mode) ->
        if mode is 'live'
            if linkName is 'index'
                return "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}"
            else
                return "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}/#{templateData.links[linkName]}"
        else
            if linkName is 'index'
                return 'index.html'
            else
                return "#{linkName}.html"

    navigation = (field, mode, active1, active2, recursed) ->
        content = "<ul>\n"

        actives = new Array()
        for arg,i in arguments
            if i >= 2
                actives.push(arg)

        for item, value of field
            isActive = false

            # if recursed
            #     icon = ""
            # else
            #     icon = "<i class=\"fa #{templateData.icons[item]}\"></i>"
 
            for active in actives
                if item is active
                    isActive = true

            if item[0] is '_'
                newItem = ''
                for i in [1..item.length-1]
                    newItem += item[i]
                item = newItem

            if typeof(value) is 'object'
                if isActive
                    content += "<li class=\"active\"><a href=\"#\"><span>#{item}</span></a>\n"
                    # content += "<li class=\"active\"><a href=\"#\"><i class=\"fa #{templateData.icons[item]}\"></i></a>\n"
                else
                    content += "<li><a href=\"#\"><span>#{item}</span></a>\n"
                    # content += "<li><a href=\"#\"><i class=\"fa #{templateData.icons[item]}\"></i></a>\n"
                # content += "<div class=\"inner-menu\"><span>#{item}</span>"
                content += navigation(value, mode, active1, active2, true)
                # content += "</div></li>"
            else
                # if item is 'index'
                #     item = 'home'
                if isActive
                    content += "<li class=\"active\"><a href=\"#{link(item, mode)}\"><span>#{value}</span></a></li>\n"
                    # content += "<li class=\"active\"><a href=\"#{link(item, mode)}\"><i class=\"fa #{templateData.icons[item]}\"></i></a>"
                else
                    content += "<li><a href=\"#{link(item, mode)}\"><span>#{value}</span></a></li>\n"
                    # content += "<li><a href=\"#{link(item, mode)}\"><i class=\"fa #{templateData.icons[item]}\"></i></a>"
                # content += "<span>#{item}</span>"
                content += "</li>\n"
        content += "</ul>\n"
 
        return content

    navigationWrapper: (mode, active1, active2) ->
        content = "<div id=\"navigation\">\n"
        content += navigation(templateData.navigation, mode, active1, active2)
        content += "</div>"

        return new hbs.SafeString(content)

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

    markdownHere: (string, options) ->
        marked.setOptions({
            highlight: (code) ->
                return highlighter.highlightAuto(code).value
        })

        handlebarsedMarkdown = hbs.compile(string)(templateData)
        markedHtml = marked(handlebarsedMarkdown)

        return new hbs.SafeString(markedHtml)

    markdown: (file) ->
        marked.setOptions({
            highlight: (code) ->
                return highlighter.highlightAuto(code).value
        })
        markdownFile = fs.readFileSync("#{__dirname}/src/markdown/#{file}.md").toString()
        handlebarsedMarkdown = hbs.compile(markdownFile)(templateData)

        content = '<div class="content" id="content-main">'
        content += '<div class="row">'

        content += '<div class="col col-lg-8 col-md-12"><div class="content-main">' + marked(handlebarsedMarkdown) + '</div></div>'
        content += '<div id="tableofcontents" class="tableofcontents affix sidebar col-lg-4 hidden-xs hidden-sm hidden-md visible-lg-3"><ul class="nav">' +
                         marked(toc(handlebarsedMarkdown, {firsth1: false, maxdepth: 5}).content).slice(4) +
                     '</div>'

        content += "</div></div>"

        return new hbs.SafeString(content)


module.exports = Helpers
