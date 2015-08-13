fs = require 'fs'
hbs = require 'handlebars'

templateData = JSON.parse(fs.readFileSync("#{__dirname}/src/template.json"))

module.exports =
    template: (templateName, mode) ->
        template = hbs.compile(fs.readFileSync("#{__dirname}/src/templates/#{templateName}.hbs", 'utf8'))
        if mode is 'dev'
            return new hbs.SafeString(template(templateData))
        else
            return new hbs.SafeString("{{#{templateData.teamName}/#{templateName}}}")
