# Bookworm

Developed by [David Andersen](http://david-andersen.me). View on Heroku [here](http://bookworm-data-insights.herokuapp.com/).

Bookworm is a single-page full stack web application built with [Express.js](http://expressjs.com/) and [AngularJS](https://angularjs.org/). It uses JavaScript and regular expressions to pull data from classic short stories.

![Screenshot](/readme_images/bookworm.png)

Version 1 includes eight stories, each by a unique author, with data on:

* Overall length
* Average sentence length
* Unique vocabulary
* Dialogue percentage
* Punctuation variety

## Layout & Design

This application uses the [Skeleton](http://getskeleton.com/) CSS framework for a two-column display and AngularJS's ``` ng-click ``` directive to render each story's data.

## Code Samples

Bookworm uses several functions to find data on each story before adding it to that story's ``` $scope ```. For example, each story's unique vocabulary is found using the function "getVocabulary" below:

```javascript

function getVocabulary(string) {
  var vocab = string.toLowerCase().replace(/(\r\n|\n|\r)/gm," ").replace(/["!.:;,?-]/g, "").split(" ");
  var uniqueWords = [];
  for (i = 0; i < vocab.length; i++) {
      var isUnique = true;
      for (j = 0; j < uniqueWords.length; j++) {
          if (vocab[i] == uniqueWords[j]) {
              isUnique = false;
          }
      }
      if (isUnique === true && vocab[i].length > 0) {
          uniqueWords.push(vocab[i]);
      }
  }
  return uniqueWords.length;
};

```

The application also scans through each text file and returns the part of the text that exists between quotation marks as dialogue, which is then rendered as a percentage using D3:

```javascript   

function getDialogue(string) {
  var quotes = string.match(/"(.*?)"/g);
  var dialogue = quotes.toString();
  return Math.round((dialogue.length / string.length) * 100);
};

```

## Coming in Version 2.0

* More data insights for each text file, including parts-of-speech analysis using the Merriam-Webster dictionary API.
* User sign-up, log-in and upload functionality.
