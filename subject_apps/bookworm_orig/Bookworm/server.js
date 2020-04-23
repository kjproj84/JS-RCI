var express    =    require('express'),
    fs         =    require('fs'),
    jquery     =    require('jquery');
var Book = require('./server/models/book');
var app = express();
app.use(express.static(__dirname + '/client'));
app.use('jquery', express.static(__dirname + '/node_modules/jquery/dist/'));
app.get('/', function(req, res){
  res.sendFile(__dirname + '/client/index.html');
});





function getSentenceAverage(array) {
  sentenceLengths = [];
  total = 0;
    for (i = 0; i < array.length; i++) {
      var sentenceLength = array[i].split(" ").length;
      sentenceLengths.push(sentenceLength);
      total += sentenceLength;
    }
    return Math.round(total / sentenceLengths.length);
};
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
function getPeriods(string) {
  var periods = string.match(/[.]/g);
  return periods.length;
};
function getCommas(string) {
  var commas = string.match(/[,]/g);
  if (commas == null) {
    return 0;
  } else {
    return commas.length;
  }
};
function getExclamations(string) {
  var exclamations = string.match(/[!]/g);
  if (exclamations == null) {
    return 0;
  } else {
    return exclamations.length;
  }
};
function getQuestions(string) {
  var questions = string.match(/[?]/g);
  if (questions == null) {
    return 0;
  } else {
    return questions.length;
  }
};
function getColons(string) {
  var colons = string.match(/[:]/g);
  if (colons == null) {
    return 0;
  } else {
    return colons.length;
  }
};
function getSemicolons(string) {
  var semicolons = string.match(/[;]/g);
  if (semicolons == null) {
    return 0;
  } else {
    return semicolons.length;
  }
};
function getDashes(string) {
  var dashes = string.match(/[--]/g);
  if (dashes == null) {
    return 0;
  } else {
    return dashes.length;
  }
};
function getDialogue(string) {
  var quotes = string.match(/"(.*?)"/g);
  var dialogue = quotes.toString();
  return Math.round((dialogue.length / string.length) * 100);
};






app.get('/api/ladywiththepetdog', function(req, res){
  fs.readFile('./client/data/theladywiththepetdog.txt', 'utf-8', function(err, data){
    var bookData = {
      text: data.replace("�", "").toString(),
      title: "The Lady with the Pet Dog",
      author: "Anton Chekhov",
      length: data.length,
      wordArray: data.split(" "),
      sentenceArray: data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf"),
      sentenceAverage: getSentenceAverage(data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf")),
      vocabulary: getVocabulary(data),
      periods: getPeriods(data),
      commas: getCommas(data),
      exclamations: getExclamations(data),
      questions: getQuestions(data),
      colons: getColons(data),
      semicolons: getSemicolons(data),
      dashes: getDashes(data),
      dialogue: getDialogue(data)
    }
    res.send(bookData);
  });
});


app.get('/api/thedead', function(req, res){
  fs.readFile('./client/data/thedead.txt', 'utf-8', function(err, data){
    var bookData = {
      text: data.replace("�", "").toString(),
      title: "The Dead",
      author: "James Joyce",
      length: data.length,
      wordArray: data.split(" "),
      sentenceArray: data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf"),
      sentenceAverage: getSentenceAverage(data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf")),
      vocabulary: getVocabulary(data),
      periods: getPeriods(data),
      commas: getCommas(data),
      exclamations: getExclamations(data),
      questions: getQuestions(data),
      colons: getColons(data),
      semicolons: getSemicolons(data),
      dashes: getDashes(data),
      dialogue: getDialogue(data)
    }
    res.send(bookData);
  });
});


app.get('/api/thecaskofamontillado', function(req, res){
  fs.readFile('./client/data/thecaskofamontillado.txt', 'utf-8', function(err, data){
    var bookData = {
      text: data.replace("�", "").toString(),
      title: "The Cask of Amontillado",
      author: "Edgar Allan Poe",
      length: data.length,
      wordArray: data.split(" "),
      sentenceArray: data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf"),
      sentenceAverage: getSentenceAverage(data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf")),
      vocabulary: getVocabulary(data),
      periods: getPeriods(data),
      commas: getCommas(data),
      exclamations: getExclamations(data),
      questions: getQuestions(data),
      colons: getColons(data),
      semicolons: getSemicolons(data),
      dashes: getDashes(data),
      dialogue: getDialogue(data)
    }
    res.send(bookData);
  });
});


app.get('/api/theredroom', function(req, res){
  fs.readFile('./client/data/theredroom.txt', 'utf-8', function(err, data){
    var bookData = {
      text: data.replace("�", "").toString(),
      title: "The Red Room",
      author: "H.G. Wells",
      length: data.length,
      wordArray: data.split(" "),
      sentenceArray: data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf"),
      sentenceAverage: getSentenceAverage(data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf")),
      vocabulary: getVocabulary(data),
      periods: getPeriods(data),
      commas: getCommas(data),
      exclamations: getExclamations(data),
      questions: getQuestions(data),
      colons: getColons(data),
      semicolons: getSemicolons(data),
      dashes: getDashes(data),
      dialogue: getDialogue(data)
    }
    res.send(bookData);
  });
});



app.get('/api/thegiftofthemagi', function(req, res){
  fs.readFile('./client/data/thegiftofthemagi.txt', 'utf-8', function(err, data){
    var bookData = {
      text: data.replace("�", "").toString(),
      title: "The Gift of the Magi",
      author: "O. Henry",
      length: data.length,
      wordArray: data.split(" "),
      sentenceArray: data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf"),
      sentenceAverage: getSentenceAverage(data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf")),
      vocabulary: getVocabulary(data),
      periods: getPeriods(data),
      commas: getCommas(data),
      exclamations: getExclamations(data),
      questions: getQuestions(data),
      colons: getColons(data),
      semicolons: getSemicolons(data),
      dashes: getDashes(data),
      dialogue: getDialogue(data)
    }
    res.send(bookData);
  });
});


app.get('/api/theyellowwallpaper', function(req, res){
  fs.readFile('./client/data/theyellowwallpaper.txt', 'utf-8', function(err, data){
    var bookData = {
      text: data.replace("�", "").toString(),
      title: "The Yellow Wallpaper",
      author: "Charlotte Perkins Gilman",
      length: data.length,
      wordArray: data.split(" "),
      sentenceArray: data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf"),
      sentenceAverage: getSentenceAverage(data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf")),
      vocabulary: getVocabulary(data),
      periods: getPeriods(data),
      commas: getCommas(data),
      exclamations: getExclamations(data),
      questions: getQuestions(data),
      colons: getColons(data),
      semicolons: getSemicolons(data),
      dashes: getDashes(data),
      dialogue: getDialogue(data)
    }
    res.send(bookData);
  });
});


app.get('/api/theoffshorepirate', function(req, res){
  fs.readFile('./client/data/theoffshorepirate.txt', 'utf-8', function(err, data){
    var bookData = {
      text: data.replace("�", "").toString(),
      title: "The Offshore Pirate",
      author: "F. Scott Fitzgerald",
      length: data.length,
      wordArray: data.split(" "),
      sentenceArray: data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf"),
      sentenceAverage: getSentenceAverage(data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf")),
      vocabulary: getVocabulary(data),
      periods: getPeriods(data),
      commas: getCommas(data),
      exclamations: getExclamations(data),
      questions: getQuestions(data),
      colons: getColons(data),
      semicolons: getSemicolons(data),
      dashes: getDashes(data),
      dialogue: getDialogue(data)
    }
    res.send(bookData);
  });
});

app.get('/api/thebigtripupyonder', function(req, res){
  fs.readFile('./client/data/thebigtripupyonder.txt', 'utf-8', function(err, data){
    var bookData = {
      text: data.replace("�", "").toString(),
      title: "The Big Trip Up Yonder",
      author: "Kurt Vonnegut",
      length: data.length,
      wordArray: data.split(" "),
      sentenceArray: data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf"),
      sentenceAverage: getSentenceAverage(data.split("...").join("asdf")
                         .split(".").join("asdf")
                         .split("!").join("asdf")
                         .split("?").join("asdf").split("asdf")),
      vocabulary: getVocabulary(data),
      periods: getPeriods(data),
      commas: getCommas(data),
      exclamations: getExclamations(data),
      questions: getQuestions(data),
      colons: getColons(data),
      semicolons: getSemicolons(data),
      dashes: getDashes(data),
      dialogue: getDialogue(data)
    }
    res.send(bookData);
  });
});






// app.listen('8080', function(){
//   console.log('Listening...');
// });


app.listen(process.env.PORT || 8080, function() {
  console.log('Server running on port 8080...');
}); //10+2*8+3+3
