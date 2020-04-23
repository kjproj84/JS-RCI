var users=[];
function getObjsInArray(obj, array) {
    var foundObjs = [];
    for (var i=0; i < array.length; i++) {
        for (var prop in obj) {
            if (obj.hasOwnProperty(prop)) {
                if (obj[prop] === array[i][prop]) {
                    foundObjs.push(array[i]);
                    break;
                }
            }
        }
    }
    return foundObjs;
}
function getUsers(searchUser) {
    return getObjsInArray(searchUser, users);
}
function users_search(input){
    var input=input;
    var output = getUsers(input);
    return output;
}
function centralized_users_search(input) {
    var output0 = users_search(input);
    var output1 = JSON.stringify(output0);
    return output1;
}
exports.getUsers = getUsers;

var input = {};
var output = centralized_users_search(input);

$('#results').text(JSON.stringify(output));
