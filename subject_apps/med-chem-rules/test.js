var koa = require('koa');
var app = koa();
var router = require('koa-router')();
app.use(router.routes());
var bodyParser = require('koa-bodyparser');
app.use(bodyParser());
