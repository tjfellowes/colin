function PopulateLocationList(location_list_id) {
    $.ajax({
        type: "GET",
        url: "/api/location",
        data: {},
        dataType: "json",
        success: function (response) {
            for (i of response) {
                $(location_list_id).append('<option value="' + i.id + '">' + i.location_path + '</option>');
            }
            $(location_list_id).selectpicker('refresh');
        }
    })
}
function PopulateUserList(user_list_id) {
    $.ajax({
        type: "GET",
        url: "/api/user",
        data: {},
        dataType: "json",
        success: function (response) {
            for (i of response) {
                $(user_list_id).append('<option value="' + i.id + '">' + i.name + '</option>');
            }
            $(user_list_id).selectpicker('refresh');
        }
    })
}
function PopulateHazClassList(hazclass_list_id) {
    $.ajax({
        type: "GET",
        url: "/api/haz_class",
        data: {},
        dataType: "json",
        success: function (response) {
            for (i of response) {
                if (i['superclass_id'] == null) {
                    $(hazclass_list_id).append('<option value="' + i.id + '">' + i.description + '</option>');
                }
            }
            $(hazclass_list_id).selectpicker('refresh');
        }
    })
}
function PopulateHazStatList(hazstat_list_id) {
    $.ajax({
        type: "GET",
        url: "/api/haz_stat",
        data: {},
        dataType: "json",
        success: function (response) {
            for (i of response) {
                $(hazstat_list_id).append('<option value="' + i.code + '">' + i.code + ' - ' + i.description + '</option>');
            }
            $(hazstat_list_id).selectpicker('refresh');
        }
    })
}
function PopulatePrecStatList(precstat_list_id) {
    $.ajax({
        type: "GET",
        url: "/api/prec_stat",
        data: {},
        dataType: "json",
        success: function (response) {
            for (i of response) {
                $(precstat_list_id).append('<option value="' + i.code + '">' + i.code + ' - ' + i.description + '</option>');
            }
            $(precstat_list_id).selectpicker('refresh');
        }
    })
}
function PopulatePictogramList(pictogram_list_id) {
    $.ajax({
        type: "GET",
        url: "/api/pictogram",
        data: {},
        dataType: "json",
        success: function (response) {
            for (i of response) {
                $(pictogram_list_id).append('<option value="' + i.id + '" data-content="<img class=&quot;img-thumbnail img-fluid&quot; style=&quot;width:50px;height:50px;&quot; src=&quot;/api/pictogram/image/id/' + i.id + '&quot;>&nbsp;' + i.name + '"></option>');
            }
            $(pictogram_list_id).selectpicker('refresh');
        }
    })
}
function PopulateSignalWordList(signal_word_list_id) {
    $.ajax({
        type: "GET",
        url: "/api/signal_word",
        data: {},
        dataType: "json",
        success: function (response) {
            for (i of response) {
                $(signal_word_list_id).append('<option value="' + i.name +'">' + i.name +'</option>');
            }
            $(signal_word_list_id).selectpicker('refresh');
        }
    })
}
