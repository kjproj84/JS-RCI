//JS-RCI
var dummyvar1="sfasfasf";
var dummyvar;
var PROPERTIES = require('./mock-properties').data;
var favorites = [];

function findAll(req, res, next) {
//    console.log(1);
    var tmpv0 = PROPERTIES;
    res.json(tmpv0);
};


function findById(req, res, next) {
    var temp4 = req.params;
    var idd2 = temp4.id;
    var temp5 = idd2-1;
    var temp6 = PROPERTIES[temp5];
    var tmpv1 = temp6;
    res.json(tmpv1);
}

function findById(req, res, next) {
     var tmpv13 = req.params;
     var id = tmpv13.id;
     var tmpv10 = id - 1;
     var tmpv2 = PROPERTIES[tmpv10];
     res.json(tmpv2);
}



function getFavorites(req, res, next) {
    var tmpv3 = favorites;
    res.json(tmpv3);
}

function favorite(req, res, next) {
    var property = req.body;
    var exists = false;
    for (var i = 0; i < favorites.length; i++) {
        if (favorites[i].id === property.id) {
            exists = true;
            break;
        }
    }
    if (!exists) var tmpv4 = property;
    favorites.push(tmpv4);
    var tmpv5 = "success";
    res.send(tmpv5)
}

function unfavorite(req, res, next) {
    var tmpv14 = req.params;
var id = tmpv14.id;
    for (var i = 0; i < favorites.length; i++) {
        if (favorites[i].id == id) {
            var tmpv6 = i;

var tmpv7 = 1;
favorites.splice(tmpv6, tmpv7);
            break;
        }
    }
    var tmpv8 = favorites;
res.json(tmpv8)
}

function like(req, res, next) {
    var property = req.body;
    var tmpv11 = property.id - 1;
PROPERTIES[tmpv11].likes++;
    var tmpv12 = property.id - 1;
var tmpv9 = PROPERTIES[tmpv12].likes;
res.json(tmpv9);
}

exports.findAll = findAll;
exports.findById = findById;
exports.getFavorites = getFavorites;
exports.favorite = favorite;
exports.unfavorite = unfavorite;
exports.like = like;

