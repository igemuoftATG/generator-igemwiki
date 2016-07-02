var system = require('system');
var args = system.args;

// args[1] -> webpage url
// args[2] -> filename
// args[3] -> size string

var sizes = {
	mobile: {
		width: 550,
		height: 1000
	},
	phablet: {
		width: 750,
		height: 1200
	},
	tablet: {
		width: 1000,
		height: 400,
	},
	desktop: {
		width: 1200,
		height: 600
	},
	desktophd: {
		width: 1920,
		height: 1080
	}
}

var page = require('webpage').create();

page.viewportSize = {
	width: sizes[args[3]].width,
	height: sizes[args[3]].height
}

page.open(args[1], function(status) {
	if (status !== 'success') {
		console.log('unable to open url ' + args[1])
	} else {
		window.setTimeout(function() {
			page.render(args[2] + '.png')
			console.log('Finished screening ' + (args[2].split('/'))[args[2].split('/').length - 1] + ' for ' + args[3])
			phantom.exit();
		}, 200);
	}
});
