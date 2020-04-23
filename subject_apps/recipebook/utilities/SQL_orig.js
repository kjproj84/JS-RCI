var mysql = require('mysql');

var connection = mysql.createConnection({
	  host: "127.0.0.1",
	    user: "root",
	      password: "password",
	      database: "mysql",
//	port: 8089

});

connection.connect(function(err) {
	  if (err) throw err;
	    console.log("Connected!");
});
//connection.query('INSERT INTO `recipes` (`id`, `user_id`, `name`) VALUES (1, 1, \'Burger\')');
//connection.query('INSERT INTO `recipes` (`id`, `user_id`, `name`) VALUES (2, 1, \'Cake\')');

//if(notExecuted){
/**
connection.query("start TRANSACTION",'' ,function (error, results, fields) {
	        console.log("started trans", error, results, fields);
		notExecuted = false;
});
**/
//}

module.exports = connection;
