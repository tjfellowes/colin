$("#location").keyup(function() {
    $.ajax({
        url: window.location.origin + "/api/location/search",
        data: {query: $("#location").val()}
    }).then(function(data) {
        $('#location_list').empty()
        for (i = 0; i < data.length; i++) {
            var location = [];
            for (j = 0; j < data[i].length; j++) {
                location.push(data[i][j].name);
            }
            $('#location_list').append("<option>" + location.join(" / ") + "</option>");
        }
    });
});