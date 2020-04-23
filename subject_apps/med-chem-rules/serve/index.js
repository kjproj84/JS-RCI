const koa = require('koa')
var bodyParser = require('koa-bodyparser');
//const koaRouter = require('koa-router')
const router = new require('koa-router')()

const send = require('koa-send')
var tmpv0 = {
  client: 'sqlite3',
  connection: {
       filename: './test222.sqlite3'
  },
  useNullAsDefault: true
};
const knex = require('knex')(tmpv0)

var app = new koa()
//app.use(bodyParser());
//const router = koaRouter()

var tmpv3 = '/';
router.get(tmpv3, function* () {
  var tmpv1 = this;

var tmpv2 = './serve/client/index.html';
yield send(tmpv1, tmpv2)
})

var tmpv6 = '/main.js';
router.get(tmpv6, function* () {
  var tmpv4 = this;

var tmpv5 = './serve/client/main.js';
yield send(tmpv4, tmpv5)
})

var tmpv9 = '/style.css';
router.get(tmpv9, function* () {
  var tmpv7 = this;

var tmpv8 = './serve/client/style.css';
yield send(tmpv7, tmpv8)
})
/**
var tmpv14 = '/h_bond_acceptors';
//router.get(tmpv14, async function (ctx) {
router.get(tmpv14, async function (ctx) {
  const sql = `
    SELECT
      h_bond_acceptor_count,
      COUNT(*) AS total
    FROM drugs WHERE h_bond_acceptor_count IS NOT NULL
    GROUP BY h_bond_acceptor_count
    ORDER BY h_bond_acceptor_count
  `
  var tmpv10 = sql;
const data = await knex.raw(tmpv10);
// const data = {"test":1999};

    var tmpv11 = { 'Content-Type': 'application/json' };
    ctx.set(tmpv11)
    var tmpv12 = data;
    console.log(tmpv12,ctx);
    var tmpv13 = data;
    var tmpv25 = JSON.stringify(tmpv13);
    ctx.body = tmpv13

});
**/
router.get('/data', async (ctx, next) => {console.log("body?", ctx);});
/**
var tmpv19 = '/molecular_weights';
router.get(tmpv19, function* () {
  console.log("this.params.id", this.request.body);
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
const data = yield knex.raw("select * from drugs");
console.log(data);
  var tmpv16 = { 'Content-Type': 'application/json' };
this.set(tmpv16)
  var tmpv17 = data;
console.log(tmpv17);
  var tmpv18 = data;
var tmpv26 = JSON.stringify(tmpv18);
this.body = tmpv26
})
**/
var tmpv20 = router.routes();
app.use(tmpv20)

var tmpv24 = process.env;
const port = tmpv24.PORT || 3099
var tmpv21 = "listening";
var tmpv22 = port;

var tmpv23 = () => console.log(tmpv21);
app.listen(tmpv22, tmpv23)

