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
        }

    capitals: (str) ->
        return str.toUpperCase()

    cssInject: (mode) ->
        content = new String()
        styles = fs.readdirSync('./src/styles')
        for stylesheet in styles
            if path.extname(stylesheet) is '.css'
                if mode is 'live'
                    content += "<link rel=\"stylesheet\" href=\"http://#{templateData.year}.igem.org/Template:#{templateData.teamName}/css/#{stylesheet}?action=raw&ctype=text/css\" type=\"text/css\" />"
                else
                    content += "<link rel=\"stylesheet\" href=\"styles/#{stylesheet}\" type=\"text/css\" />"

        return new hbs.SafeString(content)

    link: (linkName, mode) ->
        if linkName is 'index'
            return "index.html"

        if mode is 'live'
            return linkName
            # return "http://#{templateData.year}.igem.org/Team:#{templateData.teamName}/#{linkName}"
        else
            return "#{linkName}.html"

    template: (templateName, mode) ->
        template = hbs.compile(fs.readFileSync("#{__dirname}/src/templates/#{templateName}.hbs", 'utf8'))
        if mode is 'live'
            return new hbs.SafeString("{{#{templateData.teamName}/#{templateName}}}")
        else
            # Assume 'dev' mode if undefined
            # For some reason, get an extra call here with mode undefined when in dev mode
            return new hbs.SafeString(template(templateData))

module.exports = Helpers
