function abc(input){
	var tmpv5 = input;
	var tmpv4 = 'SELECT * FROM `ingredients` WHERE recipe_id = '+tmpv5;
	var alasql(tmpv4);
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
	var output = tmpv3;
	return output;
}
function abc(input){
var tmpv23 = input;
var tmpv22 = 'DELETE FROM `ingredients` WHERE `id` = '+tmpv23;
var results = alasql(tmpv22);
var tmpv21 = {};
var output = tmpv21;
return output;
}

function abc(input){
  var tmpv32 = input;
  var tmpv33 = input;
  var tmpv17 = [tmpv32.name, tmpv33.id];
  var tmpv16 = 'UPDATE `ingredients` SET name = ${tmpv17[0]} WHERE id = ${tmpv17[1]}';
  var result = alasql(tmpv16);
                var tmpv15 = {
                    'id': undefined,
                    'name': undefined
                };
var tmpv35 = input;
var tmpv47 = tmpv35.id;
tmpv15['id'] = tmpv47;
var tmpv36 = input;
var tmpv48 = tmpv36.name;
tmpv15['name'] = tmpv48;
	var output = tmpv15;
	return output;
}

app.controller('DirectionDetailsController', function ($scope, directionService, applicationSync, Notifications) {

	init();
	function init(){
		$scope.directions = [];
	}       

	$scope.$on('recipeloaded', function() {
		var id = applicationSync.message;

		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(id);
		var data = out_abcDe;
		$scope.directions = data;
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(id);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    			$scope.directions = data;
    		});
	});

});

app.controller('DirectionCreateController', function ($scope, directionService, applicationSync, Notifications) {

	init();
	function init(){
		$scope.directions = [];
	}

	$scope.addDirectionField = function(name) {
		$scope.directions.push({name:name});
	};

	$scope.removeDirectionField = function(index) {
		//var deleted = $scope.directions[index];
		$scope.directions.splice(index, 1);
	};    

	$scope.$on('recipecreated', function() {
		var id = applicationSync.message;
		var errors = false;

		for(var i in $scope.directions) {
			directionService.addDirection(id, $scope.directions[i].name).then(function(data){ 

			},
			function(error){
				errors = true;
			});	

			// if there are errors throw up a notification that not everything may have been saved
			if (errors) {
				Notifications.error('Error creating one or more directions');
			}

		}
	});
});

app.controller('DirectionEditController', function ($scope, directionService, applicationSync, Notifications) {

	init();
	function init(){
		$scope.directions = [];
		$scope.directionsRemoved = [];
	}

	$scope.addDirectionField = function(name) {
		$scope.directions.push({name:name});
	};    

	$scope.removeDirectionField = function(index) {
		var deleted = $scope.directions[index];
		$scope.directions.splice(index, 1);
		$scope.directionsRemoved.push(deleted);
	};        

	$scope.$on('recipeloaded', function() {

		var id = applicationSync.message;



		$scope.directions = directionService.getDirections(id).then(function(data){ 

			// we can get a response but there have no content
			if(typeof data !== 'undefined') {
				$scope.directions = data;
			}
			else {
				$scope.directions = [];
			}

		}, function(error){
			// trigger error message
			Notifications.error('Error fetching directions data');
			$scope.directions = [];
		});

	});

	// listen for recipe updated event that occurs in parent controller...
	$scope.$on('recipeupdated', function() {

		var recipeId = applicationSync.message;

		// add/update changed new and changed directions
		for(var i in $scope.directions) {
			if(!$scope.directions[i].hasOwnProperty('id')){
				$scope.addDirection(recipeId, $scope.directions[i].name);
			}
			else {
				$scope.updateDirection($scope.directions[i].id, $scope.directions[i].name);
			}
		}

		// delete removed directions
		for(var i in $scope.directionsRemoved) {

			// if we have an id, send a DELETE request to the server
			if(typeof $scope.directionsRemoved[i].id !== 'undefined') {

				var id =  $scope.directionsRemoved[i].id;
			$scope.deleteDirection(id);
			}
		}
	});

	// ADD Direction
	$scope.addDirection = function(recipeId, name){

		var errors = false;
		directionService.addDirection(recipeId, name).then(function(data){

		},
		function(error){
			errors = true;
		});

		// if there are errors throw up a notification that not everything may have been saved
		if (errors) {
			Notifications.error('Error updating one or more directions');
		}
	};

// UPDATE Direction
	$scope.updateDirection = function(id, name){

		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(id, name);
		var data = out_abcDe;
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(id, name);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    		});
		var errors = false;
		// if there are errors throw up a notification that not everything may have been saved
		if (errors) {
			Notifications.error('Error updating one or more directions');
		}
	};    

	// DELETE Direction
	$scope.deleteDirection = function(id){

		var errors = false;
const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(id);
		var data = out_abcDe;
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(id);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    		});
		// if there are errors throw up a notification that not everything may have been saved
		if (errors) {
			Notifications.error('Error updating one or more directions');
		}
	};    
});