var mysql = require('mysql');

var tmpv0 = {
	  host: "127.0.0.1",
	    user: "root",
	      password: "password",
	      database: "mysql",
//	port: 8089

};
var connection = mysql.createConnection(tmpv0);

function TempF1 (err) {
	  if (err) throw err;
	    var tmpv1 = "Connected!";
console.log(tmpv1);
}
var tmpv2 = TempF1;
connection.connect(tmpv2);
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
