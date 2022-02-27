function PopulateLocationList(location_list_id) {
    $.ajax({
        type: "GET",
        url: "/api/location",
        data: {},
        success: function (response) {
            for (i of response) {
            console.log(i.name);
            $(location_list_id).append('<option value="' + i.id + '">' + i.location_path + '</option>');
            }
            $(location_list_id).selectpicker('refresh');
        }
    })
}