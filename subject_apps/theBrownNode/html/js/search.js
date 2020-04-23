$(function() {
    $("#search").click(function() {
        console.log("test before");
        $.ajax({
            url: 'http://127.0.0.1:3001/users/search',
            data: {
                //firstName: $('#firstName').val(),
                //lastName: $('#lastName').val()
                firstName: "abcd",
                lastName: "edf"
            },
            type: 'POST',
          crossDomain: true,
            dataType: 'json',
            success: function(data) {
                console.log("sdfsafsafsf");
                $('#results').text(JSON.stringify(data));
            }
        });
    console.log("test after");
    });
});
