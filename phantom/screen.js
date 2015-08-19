var system = require('system');
var args = system.args;

// args[1] -> webpage url
// args[2] -> filename

var page = require('webpage').create();

// page.settings.webSecurityEnabled = false
// console.log(page.settings.webSecurityEnabled)


// page.open(args[1], function() {
// 	var ua = page.evaluate(function() {
// 		return document.getElementsByName('username')
//
// 		// document.getElementsByName('username')[0].value('test')
// 		// document.getElementsByName('password')[0].value('test')
// 		// console.log('$: ', window.jQuery)
// 	})
//
// 	// ua.forEach(function(item) {
// 	// 	console.log(item)
// 	// })
// 	page.render(args[2] + '.png')
// 	phantom.exit()
// })


// page.open(args[1], function() {
// 	page.includeJs('https://code.jquery.com/jquery-1.11.3.min.js', function() {
// 		page.evaluate(function() {
// 			console.log('inside')
// 			console.log('$: ', window.jQuery)
// 		})
// 		page.render(args[2] + '.png')
// 		phantom.exit()
// 	})
// })



page.open(args[1], function(status) {
	if (status !== 'success') {
		console.log('unable to open page')
	} else {
		var ua = page.evaluate(function() {
			var eventFire = function (el, etype){
			  if (el.fireEvent) {
			    el.fireEvent('on' + etype);
			  } else {
			    var evObj = document.createEvent('Events');
			    evObj.initEvent(etype, true, false);
			    el.dispatchEvent(evObj);
			  }
			}


			// return document.getElementById('wpTextbox1').textContent
			document.getElementsByName('username')[0].value = 'jmazz'
			document.getElementsByName('password')[0].value = 'genesquad123'
			document.getElementsByName('Login')[0].click()
			// eventFire(document.getElementsByName('Login')[0], 'click')

			return document.getElementById('table_new_user').innerHTML

			// return document.cookie
			// return page.cookies
		})
		console.log(ua)
		// page.includeJs('https://code.jquery.com/jquery-1.11.3.min.js', function() {
		// 	page.evaluate(function() {
		// 		console.log('inside')
		// 		console.log('$: ', window.jQuery)
		// 	})
		// })

		// page.evaluate(function() {
		// 	document.getElementById('user_item').click()
		// 	page.render(args[2] + 'clicked.png');
		// })
		//
		// var foo = phantom.addCookie({
		// 	'name': 'session',
		// 	'value': 'a64fbdeed63669d6b5a813347cb90144',
		// 	'path': '/',
		// 	'domain': 'http://2015.igem.org'
		// })
		// console.log(foo)

		// var cookies = page.cookies;
		//
		// console.log('Listing cookies:');
		// for (var i in cookies) {
		// 	console.log(cookies[i].name + '=' + cookies[i].value);
		// }
		//
		// console.log('url: ', page.url)
	}

	// page.includeJs('https://code.jquery.com/jquery-1.11.3.min.js', function() {
	// 	page.evaluate(function() {
	// 		console.log('inside')
	// 		console.log('$: ', window.jQuery)
	// 	})
	// })

	// console.log('cookie: ', page.cookies)
	// page.render(args[2] + '.png');

	page.onNavigationReguested = function(url, type, willNavigate, main) {
		console.log('got requrest to go to: ', url)
	}

	page.open('http://igem.org/Login_Confirmed', function() {
		page.render(args[2] + '.png')
		phantom.exit();
	})
	// phantom.exit();
});
