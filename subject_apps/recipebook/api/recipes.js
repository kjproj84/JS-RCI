var db  = require('../utilities/SQL');
var Authentication  = require('../utilities/Authentication');

module.exports = function(app) { 
   
    // GET /api/recipes
    var tmpv5 = '/api/recipes';
app.get(tmpv5, function(request, response, next){
	console.log("/api/recipes");
        var tmpv4 = 'SELECT * FROM `recipes`';
db.query(tmpv4, function (error, results, fields) {
            if(error) {
                var tmpv0 = 500;
var tmpv1 = { error: 'Error getting data' };
var tmpv37 = response.status(tmpv0);
tmpv37.send(tmpv1);
            } else {
                var data = [];
                results.forEach(function(item, index) {
                    var tmpv2 = {
                        'id': undefined,
                        'name': undefined
                    };
var tmpv55 = item['id'];
tmpv2['id'] = tmpv55;
var tmpv56 = item['name'];
tmpv2['name'] = tmpv56;
data.push(tmpv2) 
                });
                var tmpv3 = data;
		console.log(tmpv3);
response.json(tmpv3);
            }
        });        
       
    });

    // GET /api/recipes
    var tmpv12 = '/api/user/recipes/:id';
app.get(tmpv12,  function(request, response){
        var tmpv10 = 'SELECT * FROM `recipes` WHERE `user_id` = ?';

var tmpv38 = request.params;
var tmpv11 = [tmpv38.id];
db.query(tmpv10, tmpv11, function (error, results, fields) {
            if(error) {
                var tmpv6 = 500;
var tmpv7 = { error: 'Error getting data' };
var tmpv39 = response.status(tmpv6);
tmpv39.send(tmpv7);
            } else {
                var data = [];
                results.forEach(function(item, index) {
                    var tmpv8 = {
                        'id': undefined,
                        'name': undefined
                    };
var tmpv57 = item['id'];
tmpv8['id'] = tmpv57;
var tmpv58 = item['name'];
tmpv8['name'] = tmpv58;
data.push(tmpv8) 
                });                
                var tmpv9 = data;
response.json(tmpv9);
            }
        });
        
    });

    // GET /api/recipes/:id
    var tmpv18 = '/api/recipes/:id';
app.get(tmpv18, function(request, response){
	console.log("/api/recipes/:id", request.params);
        var tmpv16 = 'SELECT * FROM `recipes` WHERE `id` = ?';

var tmpv40 = request.params;
var tmpv17 = [tmpv40.id];
db.query(tmpv16, tmpv17, function (error, results, fields) {
            if(error) {
                var tmpv13 = 500;
var tmpv14 = { error: 'Error getting data' };
var tmpv41 = response.status(tmpv13);
tmpv41.send(tmpv14);
            } else {           
                var tmpv15 = { 'id': undefined, 'name': undefined };
var tmpv59 = results[0]['id'];
tmpv15['id'] = tmpv59;
var tmpv60 = results[0]['name'];
tmpv15['name'] = tmpv60;
	console.log(tmpv15);
response.json(tmpv15);
            }
        });
    });


    // POST /api/recipes/:id
    var tmpv24 = '/api/recipes/:id';
app.post(tmpv24, function(request, response){
        var tmpv22 = 'INSERT INTO `recipes` SET ?';

var tmpv23 = { 'user_id': undefined, 'name': undefined };
var tmpv42 = request.params;
var tmpv61 = tmpv42.id;
tmpv23['user_id'] = tmpv61;
var tmpv43 = request.body;
var tmpv62 = tmpv43.name;
tmpv23['name'] = tmpv62;
db.query(tmpv22, tmpv23, function (error, result, fields) {
            if(error) {
                var tmpv19 = 500;
var tmpv20 = { error: 'Error adding data' };
var tmpv44 = response.status(tmpv19);
tmpv44.send(tmpv20);
            } else {
                var tmpv21 = {
                    'id': undefined,
                    'name': undefined
                };
var tmpv63 = result.insertId;
tmpv21['id'] = tmpv63;
var tmpv45 = request.body;
var tmpv64 = tmpv45.name;
tmpv21['name'] = tmpv64;
response.json(tmpv21)
            }

        }); 
    });

    // PUT /api/recipes/:id
    var tmpv30 = '/api/recipes/:id';
app.put(tmpv30, function(request, response){
        var tmpv28 = 'UPDATE `recipes` SET name = ? WHERE id = ?';

var tmpv46 = request.body;
var tmpv47 = request.params;
var tmpv29 = [tmpv46.name, tmpv47.id];
db.query(tmpv28, tmpv29, function (error, result, fields) {
            if(error) {
                var tmpv25 = 500;
var tmpv26 = { error: 'Error updating data' };
var tmpv48 = response.status(tmpv25);
tmpv48.send(tmpv26);
            } else {
                var tmpv27 = {
                    'id': undefined,
                    'name': undefined
                };
var tmpv49 = request.params;
var tmpv65 = tmpv49.id;
tmpv27['id'] = tmpv65;
var tmpv50 = request.body;
var tmpv66 = tmpv50.name;
tmpv27['name'] = tmpv66;
response.json(tmpv27);
            }
        }); 
    });

    // DELETE /api/recipes/:id
    var tmpv36 = '/api/recipes/:id';
app.delete(tmpv36, function(request, response){
        var tmpv34 = 'DELETE FROM `recipes` WHERE `id` = ?; DELETE FROM `ingredients` WHERE `recipe_id` = ?; DELETE FROM `directions` WHERE `recipe_id` = ?';

var tmpv51 = request.params;
var tmpv52 = request.params;
var tmpv53 = request.params;
var tmpv35 = [tmpv51.id, tmpv52.id, tmpv53.id];
db.query(tmpv34, tmpv35, function (error, results, fields) {
            if(error) {
                var tmpv31 = 500;
var tmpv32 = { error: 'Error deleting data' };
var tmpv54 = response.status(tmpv31);
tmpv54.send(tmpv32);
            } else {
                var tmpv33 = {};
response.json(tmpv33);
            }
        });
    });

}

