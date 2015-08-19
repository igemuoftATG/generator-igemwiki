var system = require('system');
var args = system.args;

// PNG will have transparent parts
var format = 'png';
// JPG turns transparent parts black
// var format = 'jpg'

var page = require('webpage').create();
page.open(args[1], function() {
  page.render(args[2] + '.' + format);
  phantom.exit();
});
