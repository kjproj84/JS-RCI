var mysql = require('mysql');
/**
var connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'password',
    database: 'recipebook',
    port: 3307,
    multipleStatements: true  
});

connection.connect(function(err) {
    if (err) {
        console.error('Error: Could not connect to MySQL...\r\n');
        console.error(err.stack);
        return;
    }
    console.log('Connected to MySQL: Connected as thread ID: ' + connection.threadId);

});
**/

//var mysql = require('mysql');
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

module.exports = connection;
