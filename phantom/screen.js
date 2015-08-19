var system = require('system');
var args = system.args;

// args[1] -> webpage url
// args[2] -> filename

var page = require('webpage').create();

page.cookies = {
	_ga: 'GA1.2.705747180.1438838856',
	session: '0c9234086c57d1b047d734647064f975'
}

page.open(args[1], function(status) {
	if (status !== 'success') {
		console.log('unable to open page')
	} else {
		var ua = page.evaluate(function() {
			return document.getElementById('wpTextbox1').textContent
		})
		console.log(ua)
	}

	console.log('cookie: ', page.cookies)
	page.render(args[2] + '.png');
	phantom.exit();
});
