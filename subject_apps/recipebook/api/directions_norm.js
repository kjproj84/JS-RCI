var db  = require('../utilities/SQL');
var Authentication  = require('../utilities/Authentication');

module.exports = function(app){ 

    // GET /api/directions/:id
    var tmpv6 = '/api/directions/:id';
app.get(tmpv6, function(request, response, next){

        var tmpv4 = 'SELECT * FROM `directions` WHERE recipe_id = ?';

var tmpv25 = request.params;
var tmpv5 = [tmpv25.id];
db.query(tmpv4, tmpv5, function (error, results, fields) {
            if(error) {
                var tmpv0 = 500;
var tmpv1 = { error: 'Error getting data' };
var tmpv26 = response.status(tmpv0);
tmpv26.send(tmpv1);
            } else {
                var data = [];
                results.forEach(function(item, index) {
                    var tmpv2 = {
                        'id': undefined,
                        'recipe_id': undefined,
                        'name': undefined
                    };
var tmpv39 = item['id'];
tmpv2['id'] = tmpv39;
var tmpv40 = item['recipe_id'];
tmpv2['recipe_id'] = tmpv40;
var tmpv41 = item['name'];
tmpv2['name'] = tmpv41;
data.push(tmpv2) 
                });
                var tmpv3 = data;
response.json(tmpv3);
            }
        });        
       
    });

    // POST /api/directions
    var tmpv12 = '/api/directions';
app.post(tmpv12, function(request, response){
        var tmpv10 = 'INSERT INTO `directions` SET ?';

var tmpv11 = { 'recipe_id': undefined, 'name': undefined };
var tmpv27 = request.body;
var tmpv42 = tmpv27.recipeId;
tmpv11['recipe_id'] = tmpv42;
var tmpv28 = request.body;
var tmpv43 = tmpv28.name;
tmpv11['name'] = tmpv43;
db.query(tmpv10, tmpv11, function (error, result, fields) {
            if(error) {
                var tmpv7 = 500;
var tmpv8 = { error: 'Error adding data' };
var tmpv29 = response.status(tmpv7);
tmpv29.send(tmpv8);
            } else {
                var tmpv9 = {
                    'id': undefined,
                    'recipe_id': undefined,
                    'name': undefined
                };
var tmpv44 = result.insertId;
tmpv9['id'] = tmpv44;
var tmpv30 = request.body;
var tmpv45 = tmpv30.recipeId;
tmpv9['recipe_id'] = tmpv45;
var tmpv31 = request.body;
var tmpv46 = tmpv31.name;
tmpv9['name'] = tmpv46;
response.json(tmpv9)
            }

        }); 
    });

    // PUT /api/recipes/:id
    var tmpv18 = '/api/directions/:id';
app.put(tmpv18, function(request, response){
        var tmpv16 = 'UPDATE `directions` SET name = ? WHERE id = ?';

var tmpv32 = request.body;
var tmpv33 = request.params;
var tmpv17 = [tmpv32.name, tmpv33.id];
db.query(tmpv16, tmpv17, function (error, result, fields) {
            if(error) {
                var tmpv13 = 500;
var tmpv14 = { error: 'Error updating data' };
var tmpv34 = response.status(tmpv13);
tmpv34.send(tmpv14);
            } else {
                var tmpv15 = {
                    'id': undefined,
                    'name': undefined
                };
var tmpv35 = request.params;
var tmpv47 = tmpv35.id;
tmpv15['id'] = tmpv47;
var tmpv36 = request.body;
var tmpv48 = tmpv36.name;
tmpv15['name'] = tmpv48;
response.json(tmpv15);
            }
        }); 
    });


    // DELETE /api/directions/:id
    var tmpv24 = '/api/directions/:id';
app.delete(tmpv24,  function(request, response){
        var tmpv22 = 'DELETE FROM `directions` WHERE `id` = ?';

var tmpv37 = request.params;
var tmpv23 = [tmpv37.id];
db.query(tmpv22, tmpv23, function (error, results, fields) {
            if(error) {
                var tmpv19 = 500;
var tmpv20 = { error: 'Error deleting data' };
var tmpv38 = response.status(tmpv19);
tmpv38.send(tmpv20);
            } else {
                var tmpv21 = {};
response.json(tmpv21);
            }
        });
    });

}

