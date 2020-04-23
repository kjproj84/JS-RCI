app.controller('RecipesAllController', function ($scope, $route, recipeService, Notifications) {

	init();
	function init(){
		// get from service
		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe();
		var data = out_abcDe;
		$scope.recipes = data;
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe();
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    			$scope.recipes = data;
    		});
	}//GET recipes

	$scope.deleteRecipe = function (index) {

		var id = $scope.recipes[index].id;

		if(confirm('Are you sure you want to delete this recipe?')) {
			recipeService.deleteRecipe(id).then(function(data){
				Notifications.success('Recipe deleted successfully');
				$scope.recipes.splice(index, 1);
			}, function(error){
				Notifications.error('Error deleting recipe');
			});	    	    
		}
		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(id);
		var data = out_abcDe;
				Notifications.success('Recipe deleted successfully');
				$scope.recipes.splice(index, 1);
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe();
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    			Notifications.success('Recipe deleted successfully');
				$scope.recipes.splice(index, 1);
    		});
	  //DELETE recipe:id
	};

});

app.controller('RecipeDetailsController', function ($scope, $routeParams, recipeService, applicationSync, Notifications) {

	init();
	function init(){

		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe($routeParams.id);
		var data = out_abcDe;
		$scope.recipe = data;
		applicationSync.prepForBroadcast('recipeloaded',data.id);
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe($routeParams.id);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    			$scope.recipe = data;
				applicationSync.prepForBroadcast('recipeloaded',data.id);
    		}
    	);//GET recipe:id
	}

});


app.controller('RecipeCreateController', function ($scope, $location, recipeService, applicationSync, Notifications) {

	init();
	function init(){
	}

	$scope.createRecipe = function() {
		const IS_SYNC = false;
	  if (IS_SYNC) {
	  	var out_abcDe= abcDe(id, recipeName);
		var data = out_abcDe;
			var id = data.id;
			Notifications.success('Recipe created');
			$location.path('/recipes');
			applicationSync.prepForBroadcast('recipecreated',id);
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(id, recipeName);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    			var id = data.id;
				Notifications.success('Recipe created');
				$location.path('/recipes');
				applicationSync.prepForBroadcast('recipecreated',id);
    		});
	  //PUT recipe:id

	};
});

app.controller('RecipeEditController', function ($scope, $routeParams, $location, recipeService, applicationSync, Notifications) {

	init();
	function init(){
		$scope.recipe = recipeService.getRecipe($routeParams.id).then(function(data){
			var id = data.id;
			$scope.recipe = data;
			applicationSync.prepForBroadcast('recipeloaded',id);

		},function(error){
			Notifications.error('Error getting recipe data');
		});

	}

	$scope.updateRecipe = function() {
		var id = $scope.recipe.id;
		var name = $scope.recipe.name;
		$scope.recipe = recipeService.updateRecipe(id, name).then(function(data){
			Notifications.success('Recipe updated successfully');
			$location.path('/recipes');
			applicationSync.prepForBroadcast('recipeupdated', id);
		}, function(error){
			Notifications.error('Error updating recipe');
		});
		const IS_SYNC = false;
	  if (IS_SYNC) {
		var out_abcDe= abcDe(id, name);
		var data = out_abcDe;
		Notifications.success('Recipe updated successfully');
			$location.path('/recipes');
			applicationSync.prepForBroadcast('recipeupdated', id);
		return;
	  }//default: non-blocking async using Promise
	  new Promise((resolve,reject) => {
	  	var out_abcDe = abcDe(id, name);
	  	resolve(out_abcDe);
    	}).then(
    		res => {
    			var data = res;
    				Notifications.success('Recipe updated successfully');
			$location.path('/recipes');
			applicationSync.prepForBroadcast('recipeupdated', id);
    		});
	};

});

