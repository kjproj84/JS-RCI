$(function() {
    $("#search").click(function() {
        console.log("test before");
        $.ajax({
            //url: 'http://127.0.0.1:3001/users/search',
            url: 'http://127.0.0.1:3000/brokers/id',
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
                console.log("sdfsafsafsf\n"+JSON.stringify(data));
                $('#results').text(JSON.stringify(data));
            }
        });
    console.log("test after");
    });
});
