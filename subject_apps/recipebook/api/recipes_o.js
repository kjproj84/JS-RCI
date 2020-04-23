var db  = require('../utilities/SQL');
var Authentication  = require('../utilities/Authentication');

//var JSRCI_var = {a:9999};
var JSRCI_var = 9999;
var JSRCI_ob = {abc:1, ddd:{ccc:"string1"}};

//function aaa(a1, b1){
//  JSRCI_var = a1;		
//  JSRCI_ob = b1;		
//}

//aaa(77777, {degh:2});


module.exports = function(app) { 
    
    // GET /api/recipes
    //app.get('/api/recipes', Authentication.BasicAuthentication, function(request, response, next){
    app.get('/api/recipes', function(request, response, next){
	console.log("testing", JSRCI_var, JSRCI_ob);
	    JSRCI_var++;
	    JSRCI_ob.abc++;
	    JSRCI_ob.ddd.ccc=JSRCI_ob.ddd.ccc+"abcd";
//	response.json("success");
	var temp1 = 'SELECT * FROM `recipes`';
        db.query(temp1,'' ,function (error, results, fields) {
        //db.query('SELECT * FROM `recipes`','' ,function (error, results, fields) {
            if(error) {
                response.status(500).send({ error: 'Error getting data' });
            } else {
                var data = [];
		//console.log(results);
                results.forEach(function(item, index) {
			//console.log(item);
		//for (var key in item){
		//	console.log("##", item[key]);
		//}
                    data.push({
                        'id': item['id'],
                        'name': item['name']
                    }) 
                });
		var temp2 = data;
                response.json(temp2);
                //response.json(JSRCI_ob);
            }
        });        
       
    });

    // GET /api/recipes
    //app.get('/api/user/recipes/:id', Authentication.BasicAuthentication, function(request, response){
    app.get('/api/user/recipes/:id', function(request, response){
	var temp1 = request.params;
	var temp2 = temp1.id;

	for(var jj=1; jj<5; jj++){
	}

	console.log("GET /user/api/recipes id ", temp2);
	var ttt = 'SELECT * FROM `recipes` WHERE `user_id` = ?';
   	db.query(ttt, [temp2], function (error, results, fields) {
   	//db.query('SELECT * FROM `recipes` WHERE `user_id` = ?', [request.params.id], function (error, results, fields) {
            if(error) {
                response.status(500).send({ error: 'Error getting data' });
            } else {
                var data = [];
                results.forEach(function(item, index) {
                    data.push({
                        'id': item['id'],
                        'name': item['name']
                    }) 
                });
		var temp3 = data;		
                response.json(temp3);
            }
        });
        
    });

    // GET /api/recipes/:id
    app.get('/api/recipes/:id', function(request, response){
	var temp1 = request.params;
	var temp2 = temp1.id;

	console.log("GET /user/recipes id ", temp2, typeof temp2, typeof temp2=="string");
        db.query('SELECT * FROM `recipes` WHERE `id` = ?', [temp2], function (error, results, fields) {
            if(error||results.length==0) {
                response.status(500).send({ error: 'Error getting data' });
            } else {
	 	var temp3 = { 'id': results[0]['id'], 'name': results[0]['name'] };	    
                response.json(temp3);
            }
        });
    });


    // POST /api/recipes/:id
    app.post('/api/recipes/:id', function(request, response){
        db.query('INSERT INTO `recipes` SET ?', { 'user_id': request.params.id, 'name': request.body.name }, function (error, result, fields) {
            if(error) {
                response.status(500).send({ error: 'Error adding data' });
            } else {
                response.json({
                    'id': result.insertId,
                    'name': request.body.name
                })
            }

        }); 
    });

    // PUT /api/recipes/:id
    app.put('/api/recipes/:id', function(request, response){
        db.query('UPDATE `recipes` SET name = ? WHERE id = ?', [request.body.name, request.params.id], function (error, result, fields) {
            if(error) {
                response.status(500).send({ error: 'Error updating data' });
            } else {
                response.json({
                    'id': request.params.id,
                    'name': request.body.name
                });
            }
        }); 
    });

    // DELETE /api/recipes/:id
    app.delete('/api/recipes/:id', function(request, response){
	var temp1 = request.params;
	var temp2 = temp1.id;

        //db.query('DELETE FROM `recipes` WHERE `id` = ?; DELETE FROM `ingredients` WHERE `recipe_id` = ?; DELETE FROM `directions` WHERE `recipe_id` = ?', [request.params.id, request.params.id, request.params.id], function (error, results, fields) {
	//db.query('start TRANSACTION');
        db.query('DELETE FROM `recipes` WHERE `id` = ?', [temp1], function (error, results, fields) {
            if(error) {
                response.status(500).send({ error: 'Error deleting data' });
            } else {
		var temp3 = {};
                response.json(temp3);
            }
        });
	//db.query('ROLLBACK');
    });
}
