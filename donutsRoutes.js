var express = require('express');
var router = express.Router();
var knex = require('../db/knex');

/* GET home page. */
var tmpv0 = '/';
router.get(tmpv0, function(req, res, next) {
    var tmpv9="select * from donuts";
    knex.raw(tmpv9).then(function(donuts){
        var tmpv10 = donuts;
        res.send(tmpv10);
  });
});

var tmpv5 = '/:id';
router.get(tmpv5, function(req, res) {
var tmpv00 = req.params;
var tmpv01 = tmpv00.id;
var tmpv3 = "select * from donuts where id =" + tmpv01;
knex.raw(tmpv3).then(function(donuts){
    var tmpv4 = donuts;
    res.send(tmpv4);
  });
});


/**
var tmpv9 = '/';
router.post(tmpv9, function(req,res){
var tmpv6 = "insert into donuts (name,topping,price) values('${req.body.name}','${req.body.topping}',${req.body.price})";
knex.raw(tmpv6).then(function(){

  var tmpv7 = `select * from donuts`;
knex.raw(tmpv7).then(function(donuts){
    var tmpv8 = donuts.rows;
res.send(tmpv8);
    });
  });
});


var tmpv13 = '/:id';
router.patch(tmpv13, function(req, res) {
var tmpv10 = "update donuts set name = '${req.body.name}', topping = '${req.body.topping}' WHERE id = ${req.params.id}";
knex.raw(tmpv10).then(function(){
    var tmpv11 = "select * from donuts";
knex.raw(tmpv11).then(function(donuts){
      var tmpv12 = donuts.rows;
res.send(tmpv12);
    });
  });
});


var tmpv17 = '/:id';
router.delete(tmpv17,function(req,res){
knex.raw("begin TRANSACTION");
  var tmpv14 = `delete from donuts WHERE id = ${req.params.id}`;
knex.raw(tmpv14).then(function(){
    var tmpv15 = `select * from donuts`;
knex.raw(tmpv15).then(function(donuts){
    var tmpv16 = donuts.rows;
res.send(tmpv16);
    });
  });
knex.raw("ROLLBACK");
});

module.exports = router;

**/
