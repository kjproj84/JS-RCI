//$(function() {
//    $("#search").click(function() {
        console.log("test before");
var ajax = $.ajax;
$.ajax = function() {
    console.log('ajax: ' + JSON.stringify(arguments));
    var out = ajax.apply(this, arguments);
    console.log('ajax output: ' + JSON.stringify(arguments['url']));
    return out;
}
        // var aaa =
        // console.log(aaa);
        var input_arguments =['http://127.0.0.1:5000/brokers',{
                id: 4
            },'GET', true, 'json'];
        $.ajax({
            //url: 'http://127.0.0.1:3001/users/search',
            url: 'http://127.0.0.1:5000/brokers',
            data: {
                //firstName: $('#firstName').val(),
                //lastName: $('#lastName').val()
                //firstName: "abcd",
                //lastName: "edf"
                id: 4
            },
            type: 'GET',
          crossDomain: true,
            dataType: 'json',
            success: function(data) {
                logging("ajaxtesting", input_arguments, data);
                console.log("sdfsafsafsf\n"+JSON.stringify(data));
                $('#results').text(JSON.stringify(data));
            }
        });
    console.log("test after");
//    });
//});
