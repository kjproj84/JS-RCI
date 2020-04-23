function abc(input){
	var tmpv5 = input;
	var tmpv11 = { 'recipe_id': undefined, 'name': undefined };
	var tmpv42 = tmpv27.recipeId;
	tmpv11['recipe_id'] = tmpv42;
	var tmpv43 = tmpv28.name;
	tmpv11['name'] = tmpv43;
	var tmpv10 = 'INSERT INTO `ingredients` VALUES ';
	var result = alasql(tmpv10+JSON.stringify(tmpv11));
	var tmpv9 = {
	    'id': undefined,
	    'recipe_id': undefined,
	    'name': undefined
	};
	var tmpv44 = result;
	tmpv9['id'] = tmpv44;
	var tmpv30 = input;
	var tmpv45 = tmpv30.recipeId;
	tmpv9['recipe_id'] = tmpv45;
	var tmpv31 = input;
	var tmpv46 = tmpv31.name;
	tmpv9['name'] = tmpv46;
	var output = tmpv9;
	return output;
}
app.controller('DirectionDetailsController', function ($scope, directionService, applicationSync, Notifications) {

	init();
	function init(){
		$scope.directions = [];
	}       

	$scope.$on('recipeloaded', function() {
		var id = applicationSync.message;
		$scope.directions = directionService.getDirections(id).then(function(data){ 
			$scope.directions = data;
		}, function(error){

			Notifications.error('Error fetching directions data');

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
	  const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(recipeId, name);
		var data = out_abcDe;
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(recipeId, name);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    		});
	};

// UPDATE Direction
	$scope.updateDirection = function(id, name){

		var errors = false;
		directionService.updateDirection(id, name).then(function(data){ },
		function(error){
			errors = true;
		});	 

		// if there are errors throw up a notification that not everything may have been saved
		if (errors) {
			Notifications.error('Error updating one or more directions');
		}
	};    

	// DELETE Direction
	$scope.deleteDirection = function(id){

		var errors = false;
		directionService.deleteDirection(id).then(function(data){

		},
		function(error){
			errors = true;
		});	    

		// if there are errors throw up a notification that not everything may have been saved
		if (errors) {
			Notifications.error('Error updating one or more directions');
		}
	};    
});