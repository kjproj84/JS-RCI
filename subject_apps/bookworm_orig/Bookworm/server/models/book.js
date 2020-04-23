var mongoose = require('mongoose');

var BookSchema = new mongoose.Schema({
  title: {type: String},
  author: {type: String},
  published: {type: Number},
  content: {type: String}
});

var Book = mongoose.model('Book', BookSchema);

module.exports = Book;
