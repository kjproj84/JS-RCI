alasql("CREATE TABLE recipes (id INT, user_id INT, name STRING)");
alasql("INSERT INTO recipes VALUES (1,1, 'Burger')");
alasql("INSERT INTO recipes VALUES (2,1, 'Cake')");

function abcDe(){
	var tmpv4 = "SELECT * FROM recipes";
	var results = alasql(tmpv4);
	var data=[];
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
        var output = tmpv3;
	return output;
}

app.controller('RecipesAllController', function ($scope, $route, recipeService, Notifications) {

	init();
	function init(){
		// get from service
		$scope.recipes = abcDe();
	}

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
	};

});

app.controller('RecipeDetailsController', function ($scope, $routeParams, recipeService, applicationSync, Notifications) {

	init();
	function init(){
		recipeService.getRecipe($routeParams.id).then(function(data){
			$scope.recipe = data;
			applicationSync.prepForBroadcast('recipeloaded',data.id);

		}, function(error){
			Notifications.error('Error getting recipe data');
		});
	}

});


app.controller('RecipeCreateController', function ($scope, $location, recipeService, applicationSync, Notifications) {

	init();
	function init(){
	}

	$scope.createRecipe = function() {
		var recipeName = $scope.recipe.name;
		$scope.recipe = recipeService.addRecipe(recipeName).then(function(data){
			var id = data.id;
			Notifications.success('Recipe created');
			$location.path('/recipes');
			applicationSync.prepForBroadcast('recipecreated',id);

		}, function(error){
			Notifications.error('Error creating recipe');
		});
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
	};

});

