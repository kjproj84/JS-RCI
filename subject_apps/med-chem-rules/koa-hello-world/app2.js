var koa = require('koa')
var bodyParser = require('koa-bodyparser');
var koaRouter = require('koa-router')

//const send = require('koa-send')
/**
var tmpv0 = {
  client: 'sqlite3',
  connection: {
       filename: './test222.sqlite3'
  },
  useNullAsDefault: true
};
const knex = require('knex')(tmpv0)
**/
var app = new koa()
app.use(bodyParser());
var router = koaRouter()
var tmpv20 = router.routes();
app.use(tmpv20)

var tmpv24 = process.env;
var port = tmpv24.PORT || 3000
var tmpv21 = "listening";
var tmpv22 = port;

var tmpv23 = () => console.log(tmpv21);
app.listen(tmpv22,tmpv23)
