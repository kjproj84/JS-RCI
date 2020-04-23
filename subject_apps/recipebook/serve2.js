var express = require('express');
var hbs = require('hbs');
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');
var methodOverride = require('method-override');
var errorHandler = require('errorhandler');
var http = require('http');
var path = require('path');
var Middleware = require('./utilities/Middleware');
var app = express();
var tmpv0 = 'port';

var tmpv1 = 8085;
app.set(tmpv0, tmpv1);

var tmpv2 = 'view engine';

var tmpv3 = 'html';
app.set(tmpv2, tmpv3);
var tmpv4 = 'html';

var tmpv5 = hbs.__express;
app.engine(tmpv4, tmpv5);

/* cookie-parser - https://github.com/expressjs/cookie-parser
 Parse Cookie header and populate req.cookies with an object keyed by the cookie names. */
var tmpv6 = 'SECRETCOOKIEKEY123';
var tmpv7 = cookieParser(tmpv6);
app.use(tmpv7);
 
/* body-parser - https://github.com/expressjs/body-parser 
Node.js body parsing middleware. */
var tmpv8 = bodyParser.json();
app.use(tmpv8);
var tmpv9 = { extended: true };
var tmpv10 = bodyParser.urlencoded(tmpv9);
app.use(tmpv10);

/* method-override - https://github.com/expressjs/method-override
 Lets you use HTTP verbs such as PUT or DELETE in places where the client doesn't support it. */           
var tmpv11 = methodOverride();
app.use(tmpv11);

/* errorhandler - https://github.com/expressjs/errorhandler
 Show errors in development. */
var tmpv12 = { dumpExceptions: true, showStack: true };
var tmpv13 = errorHandler(tmpv12);
app.use(tmpv13);

var tmpv14 = __dirname;

var tmpv15 = '';
var tmpv16 = path.join(tmpv14, tmpv15);
var tmpv17 = express.static(tmpv16);
app.use(tmpv17);

var tmpv18 = Middleware.AppendPageInfo;
app.use(tmpv18);

// send app to router
var tmpv19 = app;
require('./router')(tmpv19);

function TempF1 (){
  var tmpv20 = 'port';
var tmpv21 = 'Express server listening on port ' + app.get(tmpv20);
console.log(tmpv21);
}
var tmpv22 = app;
var tmpv23 = 'port';
var tmpv24 = app.get(tmpv23);

var tmpv25 = TempF1;
var tmpv26 = http.createServer(tmpv22);
tmpv26.listen(tmpv24, tmpv25);
