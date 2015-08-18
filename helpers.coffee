fs   = require 'fs'
path = require 'path'

hbs = new Object()
templateData = new Object()

class Helpers
    constructor: (handlebars, tplateData) ->
        hbs = handlebars
        templateData = tplateData

        return {
            template  : @template
            capitals  : @capitals
            link      : @link
            cssInject : @cssInject
            jsInject  : @jsInject
        }

    capitals: (str) ->
        return str.toUpperCase()

    jsInject: (mode) ->
        content = new String()
        scripts = fs.readdirSync('./src/js')

        if mode isnt 'live'
            content += "<!-- bower:js -->\n\t<!-- endbower -->\n\t"

        for script in scripts
            if path.extname(script) is '.js'
                if mode is 'live'
                    content += "<script src=http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/js/#{script}?action=raw&type=text/js></script>\n\t"
                else
                    if script isnt 'vendor.min.js'
                        content += "<script src=\"js/#{script}\"></script>"

        return new hbs.SafeString(content)

    cssInject: (mode) ->
        content = new String()
        styles = fs.readdirSync('./src/styles')

        if mode isnt 'live'
            content += "<!-- bower:css -->\n\t<!-- endbower -->\n\t"

        for stylesheet in styles
            if path.extname(stylesheet) is '.css'
                if mode is 'live'
                    content += "<link rel=\"stylesheet\" href=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/css/#{stylesheet}?action=raw&ctype=text/css\" type=\"text/css\" />\n\t"
                else
                    if stylesheet isnt 'vendor.min.css'
                        content += "<link rel=\"stylesheet\" href=\"styles/#{stylesheet}\" type=\"text/css\" />\n\t"

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

module.exports = Helpers
