fs = require 'fs'

hbs = new Object()
templateData = new Object()

class Helpers
    constructor: (handlebars, tplateData) ->
        hbs = handlebars
        templateData = tplateData

        return {
            template : @template
            capitals : @capitals
            link     : @link
        }

    capitals: (str) ->
        return str.toUpperCase()

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
