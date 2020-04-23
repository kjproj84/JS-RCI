console.log('app.js loaded.');

angular.module('Bookworm', []);

angular.module('Bookworm')
  .controller('BookwormController', ['$scope', '$http', function($scope, $http){

    $scope.inUse = false;

    $scope.getLadyWithPetDog = function() {
      $scope.inUse = true;
      $('#puncChart').empty();
      $('#dialogueChart').empty();
        $http.get('/api/ladywiththepetdog').then(function(response){
          var text = response.data;

          $scope.book = text.text;
          $scope.bookLength = text.length;
          $scope.wordArray = text.wordArray;
          $scope.sentenceArray = text.sentenceArray;
          $scope.sentenceAverage = text.sentenceAverage;
          $scope.vocabulary = text.vocabulary;

          // Basic information
          $scope.bookTitle = text.title;
          $scope.bookAuthor = text.author;

          // Punctuation
          $scope.periods = text.periods;
          $scope.commas = text.commas;
          $scope.exclamations = text.exclamations;
          $scope.questions = text.questions;
          $scope.colons = text.colons;
          $scope.semicolons = text.semicolons;
          $scope.dashes = text.dashes;

          // Dialogue
          $scope.dialogue = text.dialogue;


          $scope.puncChart = new d3pie("puncChart", {
          	"header": {
          		"title": {
          			"text": "Punctuation",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Periods",
          				"value": text.periods,
          				"color": "#2484c1"
          			},
          			{
          				"label": "Commas",
          				"value": text.commas,
          				"color": "#0c6197"
          			},
          			{
          				"label": "Exclamation Points",
          				"value": text.exclamations,
          				"color": "#4daa4b"
          			},
          			{
          				"label": "Question Marks",
          				"value": text.questions,
          				"color": "#90c469"
          			},
          			{
          				"label": "Colons",
          				"value": text.colons,
          				"color": "#daca61"
          			},
          			{
          				"label": "Semicolons",
          				"value": text.semicolons,
          				"color": "#e4a14b"
          			},
          			{
          				"label": "Dashes",
          				"value": text.dashes,
          				"color": "#e98125"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });



          $scope.dialogueChart = new d3pie("dialogueChart", {
          	"header": {
          		"title": {
          			"text": "Dialogue",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieInnerRadius": "50%",
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Exposition",
          				"value": Math.round(((text.length - text.dialogue) / text.length) * 100),
          				"color": "#2081c1"
          			},
          			{
          				"label": "Dialogue",
          				"value": text.dialogue,
          				"color": "#fd4e35"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });
        });
    };


    $scope.getTheDead = function() {
      $scope.inUse = true;
      $('#puncChart').empty();
      $('#dialogueChart').empty();
        $http.get('/api/thedead').then(function(response){
          var text = response.data;

          $scope.book = text.text;
          $scope.bookLength = text.length;
          $scope.wordArray = text.wordArray;
          $scope.sentenceArray = text.sentenceArray;
          $scope.sentenceAverage = text.sentenceAverage;
          $scope.vocabulary = text.vocabulary;

          // Basic information
          $scope.bookTitle = text.title;
          $scope.bookAuthor = text.author;

          // Punctuation
          $scope.periods = text.periods;
          $scope.commas = text.commas;
          $scope.exclamations = text.exclamations;
          $scope.questions = text.questions;
          $scope.colons = text.colons;
          $scope.semicolons = text.semicolons;
          $scope.dashes = text.dashes;

          // Dialogue
          $scope.dialogue = text.dialogue;


          $scope.puncChart = new d3pie("puncChart", {
          	"header": {
          		"title": {
          			"text": "Punctuation",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Periods",
          				"value": text.periods,
          				"color": "#2484c1"
          			},
          			{
          				"label": "Commas",
          				"value": text.commas,
          				"color": "#0c6197"
          			},
          			{
          				"label": "Exclamation Points",
          				"value": text.exclamations,
          				"color": "#4daa4b"
          			},
          			{
          				"label": "Question Marks",
          				"value": text.questions,
          				"color": "#90c469"
          			},
          			{
          				"label": "Colons",
          				"value": text.colons,
          				"color": "#daca61"
          			},
          			{
          				"label": "Semicolons",
          				"value": text.semicolons,
          				"color": "#e4a14b"
          			},
          			{
          				"label": "Dashes",
          				"value": text.dashes,
          				"color": "#e98125"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 32
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });



          $scope.dialogueChart = new d3pie("dialogueChart", {
          	"header": {
          		"title": {
          			"text": "Dialogue",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieInnerRadius": "50%",
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Exposition",
          				"value": Math.round(((text.length - text.dialogue) / text.length) * 100),
          				"color": "#2081c1"
          			},
          			{
          				"label": "Dialogue",
          				"value": text.dialogue,
          				"color": "#fd4e35"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });
        });
    };


    $scope.getTheCask = function() {
      $scope.inUse = true;
      $('#puncChart').empty();
      $('#dialogueChart').empty();
        $http.get('/api/thecaskofamontillado').then(function(response){
          var text = response.data;

          $scope.book = text.text;
          $scope.bookLength = text.length;
          $scope.wordArray = text.wordArray;
          $scope.sentenceArray = text.sentenceArray;
          $scope.sentenceAverage = text.sentenceAverage;
          $scope.vocabulary = text.vocabulary;

          // Basic information
          $scope.bookTitle = text.title;
          $scope.bookAuthor = text.author;

          // Punctuation
          $scope.periods = text.periods;
          $scope.commas = text.commas;
          $scope.exclamations = text.exclamations;
          $scope.questions = text.questions;
          $scope.colons = text.colons;
          $scope.semicolons = text.semicolons;
          $scope.dashes = text.dashes;

          // Dialogue
          $scope.dialogue = text.dialogue;


          $scope.puncChart = new d3pie("puncChart", {
          	"header": {
          		"title": {
          			"text": "Punctuation",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Periods",
          				"value": text.periods,
          				"color": "#2484c1"
          			},
          			{
          				"label": "Commas",
          				"value": text.commas,
          				"color": "#0c6197"
          			},
          			{
          				"label": "Exclamation Points",
          				"value": text.exclamations,
          				"color": "#4daa4b"
          			},
          			{
          				"label": "Question Marks",
          				"value": text.questions,
          				"color": "#90c469"
          			},
          			{
          				"label": "Colons",
          				"value": text.colons,
          				"color": "#daca61"
          			},
          			{
          				"label": "Semicolons",
          				"value": text.semicolons,
          				"color": "#e4a14b"
          			},
          			{
          				"label": "Dashes",
          				"value": text.dashes,
          				"color": "#e98125"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });



          $scope.dialogueChart = new d3pie("dialogueChart", {
          	"header": {
          		"title": {
          			"text": "Dialogue",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieInnerRadius": "50%",
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Exposition",
          				"value": Math.round(((text.length - text.dialogue) / text.length) * 100),
          				"color": "#2081c1"
          			},
          			{
          				"label": "Dialogue",
          				"value": text.dialogue,
          				"color": "#fd4e35"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });
        });
    };


    $scope.getTheRedRoom = function() {
      $scope.inUse = true;
      $('#puncChart').empty();
      $('#dialogueChart').empty();
        $http.get('/api/theredroom').then(function(response){
          var text = response.data;

          $scope.book = text.text;
          $scope.bookLength = text.length;
          $scope.wordArray = text.wordArray;
          $scope.sentenceArray = text.sentenceArray;
          $scope.sentenceAverage = text.sentenceAverage;
          $scope.vocabulary = text.vocabulary;

          // Basic information
          $scope.bookTitle = text.title;
          $scope.bookAuthor = text.author;

          // Punctuation
          $scope.periods = text.periods;
          $scope.commas = text.commas;
          $scope.exclamations = text.exclamations;
          $scope.questions = text.questions;
          $scope.colons = text.colons;
          $scope.semicolons = text.semicolons;
          $scope.dashes = text.dashes;

          // Dialogue
          $scope.dialogue = text.dialogue;


          $scope.puncChart = new d3pie("puncChart", {
          	"header": {
          		"title": {
          			"text": "Punctuation",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Periods",
          				"value": text.periods,
          				"color": "#2484c1"
          			},
          			{
          				"label": "Commas",
          				"value": text.commas,
          				"color": "#0c6197"
          			},
          			{
          				"label": "Exclamation Points",
          				"value": text.exclamations,
          				"color": "#4daa4b"
          			},
          			{
          				"label": "Question Marks",
          				"value": text.questions,
          				"color": "#90c469"
          			},
          			{
          				"label": "Colons",
          				"value": text.colons,
          				"color": "#daca61"
          			},
          			{
          				"label": "Semicolons",
          				"value": text.semicolons,
          				"color": "#e4a14b"
          			},
          			{
          				"label": "Dashes",
          				"value": text.dashes,
          				"color": "#e98125"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });



          $scope.dialogueChart = new d3pie("dialogueChart", {
          	"header": {
          		"title": {
          			"text": "Dialogue",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieInnerRadius": "50%",
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Exposition",
          				"value": Math.round(((text.length - text.dialogue) / text.length) * 100),
          				"color": "#2081c1"
          			},
          			{
          				"label": "Dialogue",
          				"value": text.dialogue,
          				"color": "#fd4e35"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 32
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });

        });
    };


    $scope.getTheGiftOfTheMagi = function() {
      $scope.inUse = true;
      $('#puncChart').empty();
      $('#dialogueChart').empty();
        $http.get('/api/thegiftofthemagi').then(function(response){
          var text = response.data;

          $scope.book = text.text;
          $scope.bookLength = text.length;
          $scope.wordArray = text.wordArray;
          $scope.sentenceArray = text.sentenceArray;
          $scope.sentenceAverage = text.sentenceAverage;
          $scope.vocabulary = text.vocabulary;

          // Basic information
          $scope.bookTitle = text.title;
          $scope.bookAuthor = text.author;

          // Punctuation
          $scope.periods = text.periods;
          $scope.commas = text.commas;
          $scope.exclamations = text.exclamations;
          $scope.questions = text.questions;
          $scope.colons = text.colons;
          $scope.semicolons = text.semicolons;
          $scope.dashes = text.dashes;

          // Dialogue
          $scope.dialogue = text.dialogue;


          $scope.puncChart = new d3pie("puncChart", {
          	"header": {
          		"title": {
          			"text": "Punctuation",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Periods",
          				"value": text.periods,
          				"color": "#2484c1"
          			},
          			{
          				"label": "Commas",
          				"value": text.commas,
          				"color": "#0c6197"
          			},
          			{
          				"label": "Exclamation Points",
          				"value": text.exclamations,
          				"color": "#4daa4b"
          			},
          			{
          				"label": "Question Marks",
          				"value": text.questions,
          				"color": "#90c469"
          			},
          			{
          				"label": "Colons",
          				"value": text.colons,
          				"color": "#daca61"
          			},
          			{
          				"label": "Semicolons",
          				"value": text.semicolons,
          				"color": "#e4a14b"
          			},
          			{
          				"label": "Dashes",
          				"value": text.dashes,
          				"color": "#e98125"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });



          $scope.dialogueChart = new d3pie("dialogueChart", {
          	"header": {
          		"title": {
          			"text": "Dialogue",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieInnerRadius": "50%",
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Exposition",
          				"value": Math.round(((text.length - text.dialogue) / text.length) * 100),
          				"color": "#2081c1"
          			},
          			{
          				"label": "Dialogue",
          				"value": text.dialogue,
          				"color": "#fd4e35"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 32
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });

        });
    };




    $scope.getTheYellowWallpaper = function() {
      $scope.inUse = true;
      $('#puncChart').empty();
      $('#dialogueChart').empty();
        $http.get('/api/theyellowwallpaper').then(function(response){
          var text = response.data;

          $scope.book = text.text;
          $scope.bookLength = text.length;
          $scope.wordArray = text.wordArray;
          $scope.sentenceArray = text.sentenceArray;
          $scope.sentenceAverage = text.sentenceAverage;
          $scope.vocabulary = text.vocabulary;

          // Basic information
          $scope.bookTitle = text.title;
          $scope.bookAuthor = text.author;

          // Punctuation
          $scope.periods = text.periods;
          $scope.commas = text.commas;
          $scope.exclamations = text.exclamations;
          $scope.questions = text.questions;
          $scope.colons = text.colons;
          $scope.semicolons = text.semicolons;
          $scope.dashes = text.dashes;

          // Dialogue
          $scope.dialogue = text.dialogue;


          $scope.puncChart = new d3pie("puncChart", {
          	"header": {
          		"title": {
          			"text": "Punctuation",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Periods",
          				"value": text.periods,
          				"color": "#2484c1"
          			},
          			{
          				"label": "Commas",
          				"value": text.commas,
          				"color": "#0c6197"
          			},
          			{
          				"label": "Exclamation Points",
          				"value": text.exclamations,
          				"color": "#4daa4b"
          			},
          			{
          				"label": "Question Marks",
          				"value": text.questions,
          				"color": "#90c469"
          			},
          			{
          				"label": "Colons",
          				"value": text.colons,
          				"color": "#daca61"
          			},
          			{
          				"label": "Semicolons",
          				"value": text.semicolons,
          				"color": "#e4a14b"
          			},
          			{
          				"label": "Dashes",
          				"value": text.dashes,
          				"color": "#e98125"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });



          $scope.dialogueChart = new d3pie("dialogueChart", {
          	"header": {
          		"title": {
          			"text": "Dialogue",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieInnerRadius": "50%",
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Exposition",
          				"value": Math.round(((text.length - text.dialogue) / text.length) * 100),
          				"color": "#2081c1"
          			},
          			{
          				"label": "Dialogue",
          				"value": text.dialogue,
          				"color": "#fd4e35"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 32
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });

        });
    };



    $scope.getTheOffshorePirate = function() {
      $scope.inUse = true;
      $('#puncChart').empty();
      $('#dialogueChart').empty();
        $http.get('/api/theoffshorepirate').then(function(response){
          var text = response.data;

          $scope.book = text.text;
          $scope.bookLength = text.length;
          $scope.wordArray = text.wordArray;
          $scope.sentenceArray = text.sentenceArray;
          $scope.sentenceAverage = text.sentenceAverage;
          $scope.vocabulary = text.vocabulary;

          // Basic information
          $scope.bookTitle = text.title;
          $scope.bookAuthor = text.author;

          // Punctuation
          $scope.periods = text.periods;
          $scope.commas = text.commas;
          $scope.exclamations = text.exclamations;
          $scope.questions = text.questions;
          $scope.colons = text.colons;
          $scope.semicolons = text.semicolons;
          $scope.dashes = text.dashes;

          // Dialogue
          $scope.dialogue = text.dialogue;


          $scope.puncChart = new d3pie("puncChart", {
          	"header": {
          		"title": {
          			"text": "Punctuation",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Periods",
          				"value": text.periods,
          				"color": "#2484c1"
          			},
          			{
          				"label": "Commas",
          				"value": text.commas,
          				"color": "#0c6197"
          			},
          			{
          				"label": "Exclamation Points",
          				"value": text.exclamations,
          				"color": "#4daa4b"
          			},
          			{
          				"label": "Question Marks",
          				"value": text.questions,
          				"color": "#90c469"
          			},
          			{
          				"label": "Colons",
          				"value": text.colons,
          				"color": "#daca61"
          			},
          			{
          				"label": "Semicolons",
          				"value": text.semicolons,
          				"color": "#e4a14b"
          			},
          			{
          				"label": "Dashes",
          				"value": text.dashes,
          				"color": "#e98125"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });



          $scope.dialogueChart = new d3pie("dialogueChart", {
          	"header": {
          		"title": {
          			"text": "Dialogue",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieInnerRadius": "50%",
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Exposition",
          				"value": Math.round(((text.length - text.dialogue) / text.length) * 100),
          				"color": "#2081c1"
          			},
          			{
          				"label": "Dialogue",
          				"value": text.dialogue,
          				"color": "#fd4e35"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 32
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });

        });
    };




    $scope.getTheBigTripUpYonder = function() {
      $scope.inUse = true;
      $('#puncChart').empty();
      $('#dialogueChart').empty();
        $http.get('/api/thebigtripupyonder').then(function(response){
          var text = response.data;

          $scope.book = text.text;
          $scope.bookLength = text.length;
          $scope.wordArray = text.wordArray;
          $scope.sentenceArray = text.sentenceArray;
          $scope.sentenceAverage = text.sentenceAverage;
          $scope.vocabulary = text.vocabulary;

          // Basic information
          $scope.bookTitle = text.title;
          $scope.bookAuthor = text.author;

          // Punctuation
          $scope.periods = text.periods;
          $scope.commas = text.commas;
          $scope.exclamations = text.exclamations;
          $scope.questions = text.questions;
          $scope.colons = text.colons;
          $scope.semicolons = text.semicolons;
          $scope.dashes = text.dashes;

          // Dialogue
          $scope.dialogue = text.dialogue;


          $scope.puncChart = new d3pie("puncChart", {
          	"header": {
          		"title": {
          			"text": "Punctuation",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Periods",
          				"value": text.periods,
          				"color": "#2484c1"
          			},
          			{
          				"label": "Commas",
          				"value": text.commas,
          				"color": "#0c6197"
          			},
          			{
          				"label": "Exclamation Points",
          				"value": text.exclamations,
          				"color": "#4daa4b"
          			},
          			{
          				"label": "Question Marks",
          				"value": text.questions,
          				"color": "#90c469"
          			},
          			{
          				"label": "Colons",
          				"value": text.colons,
          				"color": "#daca61"
          			},
          			{
          				"label": "Semicolons",
          				"value": text.semicolons,
          				"color": "#e4a14b"
          			},
          			{
          				"label": "Dashes",
          				"value": text.dashes,
          				"color": "#e98125"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 16
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });



          $scope.dialogueChart = new d3pie("dialogueChart", {
          	"header": {
          		"title": {
          			"text": "Dialogue",
          			"fontSize": 24,
          			"font": "open sans"
          		},
          		"subtitle": {
          			"color": "#999999",
          			"fontSize": 12,
          			"font": "open sans"
          		},
          		"location": "top-left",
          		"titleSubtitlePadding": 9
          	},
          	"footer": {
          		"color": "#999999",
          		"fontSize": 10,
          		"font": "open sans",
          		"location": "bottom-left"
          	},
          	"size": {
          		"canvasHeight": 350,
          		"canvasWidth": 350,
          		"pieInnerRadius": "50%",
          		"pieOuterRadius": "90%"
          	},
          	"data": {
          		"sortOrder": "value-desc",
          		"content": [
          			{
          				"label": "Exposition",
          				"value": Math.round(((text.length - text.dialogue) / text.length) * 100),
          				"color": "#2081c1"
          			},
          			{
          				"label": "Dialogue",
          				"value": text.dialogue,
          				"color": "#fd4e35"
          			}
          		]
          	},
          	"labels": {
          		"outer": {
          			"pieDistance": 32
          		},
          		"inner": {
          			"hideWhenLessThanPercentage": 3
          		},
          		"mainLabel": {
          			"fontSize": 11
          		},
          		"percentage": {
          			"color": "#ffffff",
          			"decimalPlaces": 0
          		},
          		"value": {
          			"color": "#adadad",
          			"fontSize": 11
          		},
          		"lines": {
          			"enabled": true
          		},
          		"truncation": {
          			"enabled": true
          		}
          	},
          	"effects": {
          		"pullOutSegmentOnClick": {
          			"effect": "linear",
          			"speed": 400,
          			"size": 8
          		}
          	},
          	"misc": {
          		"gradient": {
          			"enabled": true,
          			"percentage": 100
          		}
          	}
          });

        });
    };




  }]);
