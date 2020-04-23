var express = require('express');
var app = express.createServer();
var _ = require("./html/js/Underscore");

var test = require("./html/js/testing");
var serverTests = test.testingObj;

serverTests.setDefaults({
    useConsole:true,
    isAjax:false
});
var obj = {testKey:"testValue"};
var arr = [{testKey:"testValue"},{testKey2:"testValue2"}];

serverTests.addToTests({
    desc: 'getObjsInArray, obj:{testKey:"testValue"}, arr:[{testKey:"testValue"},{testKey2:"testValue2"}]',
    testFunction : function () { 
        return (getObjsInArray(obj, arr).length > 0 && getObjsInArray(obj, arr)[0].testKey === obj.testKey); 
    }
});

serverTests.addToTests({
    desc: 'getObjIndicesInArray, obj:{testKey:"testValue"}, arr:[{testKey:"testValue"},{testKey2:"testValue2"}]',
    testFunction : function () { 
        return ((getObjIndicesInArray(obj, arr).length > 0) && (getObjIndicesInArray(obj, arr)[0] === 0)); 
    }
});

serverTests.runTests();

app.configure(function(){
    app.use(express.static(__dirname + '/html'));
    //app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
    app.use(express.bodyParser());
});

var users = [];

// Return all users that have a property and value matched by the passed searchUser


function getObjsInArray_b(obj, array) {
    var foundObjs = [];
    for (var i = 0; i < array.length; i++) {
	// console.log("@@@@@@@\n"+JSON.stringify(obj));
        for(var prop in obj) {
            if(obj.hasOwnProperty(prop)) {
                //console.log(prop);
                if (obj[prop] === array[i][prop]) {
                    foundObjs.push(array[i]);
                    break;
                }
            }
        }  
    }
    return foundObjs;
}


function getObjsInArray(obj, array) {
    var foundObjs = [];
    var keys = Object.keys(obj);
    for (var i = 0; i < array.length; i++) {
        for (var j = 0, l = keys.length; j < l; j++) {
            var key = keys[j];
            if (obj[key] === array[i][key]) {
                foundObjs.push(array[i]);
                break;
            }
        }
    }
    return foundObjs;
}

function getObjIndicesInArray(obj, array) {
    var foundIndices = [];
    for (var i = 0; i < array.length; i++) {
        for(var prop in obj) {
            if(obj.hasOwnProperty(prop)) {
                if (obj[prop] === array[i][prop]) {
                    foundIndices.push(i);
                    break;
                }
            }
        }  
    }
    return foundIndices;
}

function getUsers(searchUser) {
    return getObjsInArray(searchUser, users);
}

function getUserIndices(searchUser) {
    return getObjIndicesInArray(searchUser, users);
}

function updateUser(searchUser) {
    var foundUsers = [];
    var user_id = parseInt(searchUser.id, 10);
    var foundUserIndices = getUserIndices({ id: user_id });
    if (foundUserIndices.length > 0) {
        _.extend(users[foundUserIndices[0]], searchUser);
        foundUsers.push(users[foundUserIndices[0]]);
    }
    return foundUsers;
}

//users.push(newUser("fred","flintstone"));
//users.push(newUser("doug","funny")); //This was Ez's idea

app.get('/mods', function(request, response) {
    response.send('what mods?');
});

app.get("/users", function(req, res) {
    res.send(users);    
});

app.post("/users/add", function(req, res) {
    users.push(req.body);
    var user = users[users.length - 1];
    user.id = users.length;
    user.active = false;
    res.send(user);
});

app.get("/users/search/:name", function(req, res, next) {
    var searchResults = getUsers({ name: req.params.name }) ;
    if ( searchResults.length > 0 ) {
        res.send( searchResults );
    }
    else
        next();
});

app.get("/users/search/:id", function(req, res) {
    // res.send( getUsers({ id: parseInt(req.params.id, 10) }) );
    cnt++;
    var start = process.hrtime();
    var input= { name: "John111", age: 24 ,p0:10,p1:11,p2:12,p3:13,p4:14,p5:15,p6:16,p7:17,id:1};
    for (var i=0;i<10000;i++) {
        var output = getUsers({ id: parseInt(input.id, 10) });
    }
    var stop = process.hrtime();
    // var timea = stop[0] * 1e9 + stop[1] -(start[0] * 1e9 + start[1]);
    // console.log(start[0] * 1e9 + start[1], );
    startMin=Math.min(startMin, start[0] * 1e9 + start[1]);
    stopMax=Math.max(stopMax, stop[0] * 1e9 + stop[1]);
    diff = diff + stopMax, stop[0] * 1e9 + stop[1] - (startMin, start[0] * 1e9 + start[1])

    // console.log(getUsers(input));
    res.send(output);

});



app.post("/users/update", function(req, res) {
    res.send(updateUser(req.body));
});

var startMin =999999999999999999999;
var stopMax =0;
var cnt = 0;
var diff = 0;

app.post('/users/search', function(req, res) {
    // Pass the POST body which is assumed, maybe incorrectly, to be json
    // console.log('/users/search');
    cnt++;
    var start = process.hrtime();
    var input= { name: "John111", age: 24 ,p0:10,p1:11,p2:12,p3:13,p4:14,p5:15,p6:16,p7:17,id:1};
    for (var i=0;i<100;i++) {
        var output = getUsers(input);
    }
    var stop = process.hrtime();
    // var timea = stop[0] * 1e9 + stop[1] -(start[0] * 1e9 + start[1]);
    // console.log(start[0] * 1e9 + start[1], );
    startMin=Math.min(startMin, start[0] * 1e9 + start[1]);
    stopMax=Math.max(stopMax, stop[0] * 1e9 + stop[1]);
    diff = diff + stopMax, stop[0] * 1e9 + stop[1] - (startMin, start[0] * 1e9 + start[1])

    // console.log(getUsers(input));
    res.send(output);
});

// app.get("/:name",function(req,res){
//     res.sendfile("html/" + req.params.name + ".html")
// });

app.get('/', function(request, response) {
  response.send('Hello World!, i am using express');
});

//var port = process.env.C9_PORT || process.env.PORT || 63342;
var port = 3001;

app.listen(port, function() {
  console.log("Listening on " + port);
});


var http = require('http');

var options = {
    host: '127.0.0.1',
    port: 3001,
    path: '/users/search',
    method: 'POST',
};
/**
var req = http.request(options, function (res) {
    var responseString = "";

    res.on("data", function (data) {
        responseString += data;
        // save all the data from response
    });
    res.on("end", function () {
        console.log(responseString);
        // print to console when response ends
    });
});
var reqBody = "sometext";
req.write(reqBody);
req.write(reqBody);

 setTimeout(function() { req.write(reqBody) }, 5);

**/

let john = { name: "John", age: 25 ,p0:0,p1:1,p2:2,p3:3,p4:4,p5:5,p6:6,p7:7,id:1};
let john26 = { name: "John", age: 26 ,p0:0,p1:1,p2:2,p3:3,p4:4,p5:5,p6:6,p7:7,id:2};
//
let adam = { name: "Adam", age: 30 ,p0:0,p1:1,p2:2,p3:3,p4:4,p5:5,p6:6,p7:7,id:3};
let mary = { name: "Mary", age: 28 ,p0:0,p1:1,p2:2,p3:3,p4:4,p5:5,p6:6,p7:7,id:4};

// var before = require('./insourced_web_before.js');
// var after = require('./insourced_web_after.js');

users.push(john);
users.push(john26);
users.push(adam);
users.push(mary);

function doHTTPRequest() {
    var options = {
        host: '127.0.0.1',
        port: 3001,
        path: '/users/search/:id',
        method: 'GET',
    };

    http.get(options, function(res) {
        setTimeout(doHTTPRequest, 1);
    }).on('error', function(e) {
        setTimeout(doHTTPRequest, 1);
    });
}


doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();doHTTPRequest();
doHTTPRequest();
doHTTPRequest();
doHTTPRequest();

setInterval(function() {
    // console.log("naive:", msFromStart(), process.memoryUsage().heapUsed, total);
    console.log("naive:", startMin, stopMax, cnt, (stopMax-startMin)/(cnt*1e6)+"ms "+ diff/(cnt*1e6));
    // memwatch.gc();
    // var hde = hd.end();
    //
    // console.log(+"\n@@@@"+cnt);
    // console.log(hde.change.size+"\n@@@@"+cnt);
    // hd = new memwatch.HeapDiff();

}, 200);

/**
function doHTTPRequest() {
    var options = {
        host: '127.0.0.1',
        port: 3001,
        path: '/users/search'
    };

    http.get(options, function(res) {
        setTimeout(doHTTPRequest, 5);
    }).on('error', function(e) {
        setTimeout(doHTTPRequest, 5);
    });
}
**/
//doHTTPRequest();
//doHTTPRequest();
/**
var request = require('request');

var aaa = request.post(
    'http://127.0.0.1/users/search',
    { json: { key: 'value' } },
    function (error, response, body) {
        if (!error && response.statusCode == 200) {
            console.log(body);
        }
        setTimeout(aaa, 5);
    }
);
 **/