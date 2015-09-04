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

module.exports = generators.Base.extend({
	// The name `constructor` is important here
	constructor: function() {
		// Calling the super constructor is important so our generator is correctly set up
		generators.Base.apply(this, arguments);

		// Next, add your custom code
		this.option('coffee'); // This method adds support for a `--coffee` flag
	},
	method1: function() {
		console.log('method 1 just ran');
	},
	method2: function() {
		console.log('method 2 just ran');
	}
});
