//var app = require('./app_koa').app;
//var router = require('./app_koa').router;
//var bodyParser = require('koa-bodyparser');
//var koaRouter = require('koa-router')

//const router = koaRouter()
//const send = require('koa-send')

var Koa = require('koa');
var app = new Koa();

//const main = ctx => {
//  ctx.response.body = 'Hello World';
//};

//app.use(function(ctx){
//	  ctx.response.body = 'Hello World';
//});


var tmpv0 = {
  client: 'sqlite3',
  connection: {
       filename: './test222.sqlite3'
  },
  useNullAsDefault: true
};
//var knex = require('knex')(tmpv0)

//var app = new koa()
//app.use(bodyParser());
//const router = koaRouter()
/**
var tmpv3 = '/';
router.get(tmpv3, async function () {
  var tmpv1 = this;

var tmpv2 = './serve/client/index.html';
await send(tmpv1, tmpv2)
})

var tmpv6 = '/main.js';
router.get(tmpv6, async function() {
  var tmpv4 = this;

var tmpv5 = './serve/client/main.js';
await send(tmpv4, tmpv5)
})

var tmpv9 = '/style.css';
router.get(tmpv9, async function () {
  var tmpv7 = this;

var tmpv8 = './serve/client/style.css';
await send(tmpv7, tmpv8)
})
**/
var tmpv14 = '/h_bond_acceptors';
app.use (function (ctx) {
//router.get(tmpv14,  function (ctx) {
  var sql = `
    SELECT
      h_bond_acceptor_count,
      COUNT(*) AS total
    FROM drugs WHERE h_bond_acceptor_count IS NOT NULL
    GROUP BY h_bond_acceptor_count
    ORDER BY h_bond_acceptor_count
  `;
  var tmpv10 = sql;
  console.log(sql);
  
  //var data = knex.raw(tmpv10);
  return new Promise(function (resolve, reject) {
	  /**
      knex.raw(tmpv10).then(function(data){
        console.log(data);
      	var tmpv11 = { 'Content-Type': 'application/json' };
    	ctx.set(tmpv11);
    	var tmpv13 = data;
        var tmpv25 = JSON.stringify(tmpv13);
	**/
        //ctx.body = tmpv25;
        ctx.body = "test";

    	resolve();
   //   });
  });
  
  /**
  knex.raw(tmpv10).then(function(data){
	  console.log(data);
    var tmpv11 = { 'Content-Type': 'application/json' };
    ctx.set(tmpv11);
    var tmpv13 = data;
    var tmpv25 = JSON.stringify(tmpv13);
    ctx.body = tmpv25;
    resolve();
  });
**/
  /**
  const data = await knex.raw(tmpv10);
  var tmpv11 = { 'Content-Type': 'application/json' };
  ctx.set(tmpv11);
  var tmpv13 = data;
  var tmpv25 = JSON.stringify(tmpv13);
  ctx.body = tmpv25
  **/
})

/**
var tmpv19 = '/molecular_weights';
router.get(tmpv19, async function (ctx) {
  // console.log("this.params.id", this.request.body);
  const sql = `
   WITH intervals AS (
      SELECT CAST(molecular_weight AS INT) / 10.0* 10 AS weight_interval
      FROM drugs WHERE molecular_weight IS NOT NULL AND CAST(molecular_weight AS INT)< 1000
      )
       SELECT
         weight_interval,
         count(*) AS total
       FROM intervals
       GROUP BY weight_interval
       ORDER BY weight_interval;
	  `
  var tmpv15 = sql;
  const data = await knex.raw(tmpv15);
  var tmpv16 = { 'Content-Type': 'application/json' };
ctx.set(tmpv16);
  var tmpv17 = data;
console.log(tmpv17);
  var tmpv18 = data;
var tmpv26 = JSON.stringify(tmpv18);
ctx.body = tmpv26
})
**/
//var tmpv20 = router.routes();
//app.use(tmpv20)
/**
var tmpv24 = process.env;
const port = tmpv24.PORT || 3000
var tmpv21 = "listening";
var tmpv22 = port;

var tmpv23 = () => console.log(tmpv21);
**/
app.listen(3000)
