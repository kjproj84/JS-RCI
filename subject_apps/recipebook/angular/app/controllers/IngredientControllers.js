app.controller('IngredientDetailsController', function ($scope, ingredientService, applicationSync, Notifications) {

	init();
	function init(){
		$scope.ingredients = [];
	}       

	$scope.$on('recipeloaded', function() {

		var id = applicationSync.message;
		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(id);
		var data = out_abcDe;
		$scope.recipes = data;
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(id);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    			$scope.ingredients  = data;
    		});
	});
});

app.controller('IngredientCreateController', function ($scope, ingredientService, applicationSync, Notifications) {

	init();
	function init(){
		$scope.ingredients = [];
	}

	$scope.addIngredientField = function(name) {
		$scope.ingredients.push({name:name});
	};    

	$scope.removeIngredientField = function(index) {
		//var deleted = $scope.ingredients[index];
		$scope.ingredients.splice(index, 1);
	};        

	$scope.$on('recipecreated', function() {

		var id = applicationSync.message;
		var errors = false;
		for(var i in $scope.ingredients) {
			const IS_SYNC = false;
			  if (IS_SYNC) {
				var out_abcDe= abcDe(id, $scope.ingredients[i].name);
				var data = out_abcDe;
				return;
			  }//default: non-blocking async using Promise
			  new Promise((resolve,reject) => {
				var out_abcDe = abcDe(id, $scope.ingredients[i].name);
				resolve(out_abcDe);
				}).then(
					res => {
						var data = res;
					});
			// if there are errors throw up a notification that not everything may have been saved
			if (errors) {
				Notifications.error('Error creating one or more ingredients');
			}
		}

	});
});

app.controller('IngredientEditController', function ($scope, ingredientService, applicationSync, Notifications) {

	init();
	function init(){
		$scope.ingredients = [];
		$scope.ingredientsRemoved = [];
	}

	$scope.addIngredientField = function(name) {
		$scope.ingredients.push({name:name});
	};    

	$scope.removeIngredientField = function(index) {
		var deleted = $scope.ingredients[index];
		$scope.ingredients.splice(index, 1);
		$scope.ingredientsRemoved.push(deleted);
	};        

	$scope.$on('recipeloaded', function() {

		var id = applicationSync.message;

		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(id);
		var data = out_abcDe;
					if(typeof data !== 'undefined') {
				$scope.ingredients = data;
			}
			else {
				$scope.ingredients = [];
			}
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(id);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    						if(typeof data !== 'undefined') {
				$scope.ingredients = data;
			}
			else {
				$scope.ingredients = [];
			}
    		});
	});

	// listen for recipe updated event that occurs in parent controller...
	$scope.$on('recipeupdated', function() {

		var recipeId = applicationSync.message;

		// add/update changed new and changed ingredients
		for(var i in $scope.ingredients) {

			if(!$scope.ingredients[i].hasOwnProperty('id')){
				$scope.addIngredient(recipeId, $scope.ingredients[i].name);
			}
			else {
				$scope.updateIngredient($scope.ingredients[i].id, $scope.ingredients[i].name);
			}
		}

		// delete removed ingredientes
		for(var i in $scope.ingredientsRemoved) {

			// if we have an id, send a DELETE request to the server
			if(typeof $scope.ingredientsRemoved[i].id !== 'undefined') {

				var id =  $scope.ingredientsRemoved[i].id;
				$scope.deleteIngredient(id);
			}
		}
	});

	// ADD Ingredient
	$scope.addIngredient = function(recipeId, name){
		var errors = false;
		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(recipeId,name);
		var data = out_abcDe;
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(recipeId,name);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    		});
		// if there are errors throw up a notification that not everything may have been saved
		if (errors) {
			Notifications.error('Error updating one or more ingredients');
		}
	};

	// 1UPDATE Ingredient
	$scope.updateIngredient = function(id, name){

		var errors = false;
			const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(id, name);
		var data = out_abcDe;
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(id,name);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    		});
		// if there are errors throw up a notification that not everything may have been saved
		if (errors) {
			Notifications.error('Error updating one or more ingredients');
		}
	};    

	// DELETE Ingredient
	$scope.deleteIngredient = function(id){

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
			Notifications.error('Error updating one or more ingredients');
		}

	};    

});