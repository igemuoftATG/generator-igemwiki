// Extending a base generator

// var generators = require('yeoman-generator');
//
// module.exports = generators.Base.extend();

// If you'd like to require a name argument for your generator (for example foo
// in yo name:router foo) that will be assigned to this.name, you can instead do
// the following:

// var generators = require('yeoman-generator');
//
// module.exports = generators.NamedBase.extend();

var generators = require('yeoman-generator');
var colors = require('colors');
var requestSync = require('sync-request');
var cheerio = require('cheerio');

module.exports = generators.Base.extend({
	// The name `constructor` is important here
	constructor: function() {
		// Calling the super constructor is important so our generator is correctly set up
		generators.Base.apply(this, arguments);

		// --skip-install flag
		this.option('skip-install');
		this.option('skip-repo');
	},
	initializing: function() {
		// this.log('destinationRoot', this.destinationRoot());
		// this.log('sourceRoot', this.sourceRoot());
	},
	prompting: function() {
		var done = this.async();

		var questions = [{
			type: 'input',
			name: 'year',
			message: 'What year is it?',
			default: (new Date()).getFullYear()
		}, {
			type: 'input',
			name: 'teamName',
			message: 'What is your team name ' + 'exactly'.red + ' as it appears on the wiki? (Team:' + 'teamName'.magenta + ')',
			validate: function(input) {
				if (input === '') {
					return false;
				} else {
					return true;
				}
			}
		}];

		if (!this.options['skip-repo']) {
			questions.push({
					type: 'input',
					name: 'repo',
					message: 'What is the GitHub repository for this project? (Provided as ' + 'username/repo'.magenta + ')',
					validate: function(input) {
						var good = false
						for (var i = 0; i < input.length; i++) {
							if (input[i] === '/' && good === false) {
								good = true;
							} else if (input[i] === '/' && good === true) {
								good = false;
								return;
							}
						}

						if (!good)
							return 'Follow ' + 'username'.magenta + '/' + 'repo'.magenta + ' format.'

						base_url = 'https://github.com/'

						var httpResponse = requestSync('GET', base_url + input);

						if (httpResponse.statusCode === 200) {
							return true
						} else if (httpResponse.statusCode === 404) {
							return 'Nice try, the page ' + base_url.blue + input.blue + ' returned a ' + '404'.red
						} else {
							return false
						}
					}
				})
			}

			this.prompt(questions, function(answers) {
				this.answers = {
						year: answers.year,
						teamName: answers.teamName,
						repo: answers.repo
					}
					// this.log(answers.year);
					// this.log(answers.teamName)
				done();
			}.bind(this));
	},
	configuring: function() {
		this.log('configuring');
	},
	default: function() {
		this.log('default');
	},
	writing: function() {
		// this.log('writing');
		this.fs.copyTpl(
			this.templatePath('template.json'),
			this.destinationPath('src/template.json'),
			this.answers
		)
	},
	install: function() {
		if (this.options['skip-install']) {
			this.log('Skipping ' + 'npm install'.magenta + ' and ' + 'bower install'.magenta + '. Run these yourself.')
		} else {
			this.installDependencies()
		}
	},
	end: function() {
		this.log('end');
	}
});
