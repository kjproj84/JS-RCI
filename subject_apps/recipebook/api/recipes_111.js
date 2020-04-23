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



function TempF1  (error, results, fields) {      
  var data = [];
  results.forEach(function(item, index) {
	    data.push({
		'id': item['id'],
		'name': item['name']
	    }) 
  });	
  var temp3 = results;
  response.json(temp3);
}

function TempF22(request, response){
	var tmpv7 = request.params;
	var tmpv77 = tmpv7.id;
	var tmpv2 = [tmpv77];
	console.log("TempF22");
	var tmpv1 = 'SELECT * FROM `recipes` WHERE `user_id` = ?';
        db.query(tmpv1, tmpv2 , TempF1);   
}


module.exports = function(app) { 
    
   app.get('/api/user/recipes/:id', TempF22);
}
