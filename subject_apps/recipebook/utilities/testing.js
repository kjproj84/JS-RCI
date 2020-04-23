var db= require("./SQL");


var temp2 = 'START TRANSACTION';
var temp1 = 'SELECT * FROM `recipes`';
var temp3 = 'ROLLBACK'


//db.query('INSERT INTO `recipes` (`id`, `user_id`, `name`) VALUES (1, 1, \'Burger\')');
//return;
//db.query(temp2,'' ,function (error, results, fields) {
//	console.log(error, results, fields);	
//});

db.query(temp1,'' ,function (error, results, fields) {
	console.log(results);	
});



db.query('DELETE FROM recipes WHERE id=1','' ,function (error, results, fields) {
	console.log(results);	
});
db.query(temp1,'' ,function (error, results, fields) {
	console.log("AFTER", results);	
});

db.query(temp3,'' ,function (error, results, fields) {
	console.log(error, results, fields);	
});

db.query(temp1,'' ,function (error, results, fields) {
	console.log(results);	
});

/**
db.query(temp1,'' ,function (error, results, fields) {
	console.log(results);	
});


db.query(temp1,'' ,function (error, results, fields) {
	console.log(results);	
});
**/

//DELETE FROM recipes WHERE id=1
