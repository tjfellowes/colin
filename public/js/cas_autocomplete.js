$( "#cas" ).autocomplete({
    source: function(request, response){
        $.ajax({
            url: '/api/chemical/cas/' + request.term,
            type: "GET",
            dataType: "json",
            success: function (data) {
                chemicals = data;
                response($.map(chemicals, function(item) {
                    return {
                        label: item.cas,
                        value: item.cas
                    };
                }
                ));  
            } 
        });//ajax ends 
    },
    close: function(){
        console.log(chemicals)
        if (chemicals.length == 1) {
            dg_class = "";
            if (chemicals[0].dg_class_1) {dg_class = dg_class.concat(chemicals[0].dg_class_1.number );}
            if (chemicals[0].dg_class_2 && !chemicals[0].dg_class_3) {dg_class = dg_class.concat(' (' + chemicals[0].dg_class_2.number + ')');}
            if (chemicals[0].dg_class_2 && chemicals[0].dg_class_3) {dg_class = dg_class.concat(' (' + chemicals[0].dg_class_2.number + ', ' + chemicals[0].dg_class_3.number + ')');}
            $("#cas").val(chemicals[0]['cas']);
            $("#prefix").val(chemicals[0]['prefix']).attr('disabled', true);
            $("#name").val(chemicals[0]['name']).attr('disabled', true);
            $("#inchi").val(chemicals[0]['inchi']).attr('disabled', true);
            $("#smiles").val(chemicals[0]['smiles']).attr('disabled', true);
            $("#pubchem").val(chemicals[0]['pubchem']).attr('disabled', true);
            $("#density").val(chemicals[0]['density']).attr('disabled', true);
            $("#melting_point").val(chemicals[0]['melting_point']).attr('disabled', true);
            $("#boiling_point").val(chemicals[0]['boiling_point']).attr('disabled', true);
            $("#haz_stats").val('wub').attr('disabled', true);
            $("#prec_stats").val(chemicals[0]['XXX']).attr('disabled', true);
            $("#un_number").val(chemicals[0]['un_number']).attr('disabled', true);
            $("#un_proper_shipping_name").val(chemicals[0]['un_proper_shipping_name']).attr('disabled', true);
            $("#dg_class").val(dg_class).attr('disabled', true);
            $("#packing_group").val(chemicals[0].packing_group && chemicals[0].packing_group.name).attr('disabled', true);
            $("#schedule").val(chemicals[0].schedule && chemicals[0].schedule.number).attr('disabled', true);
        }
        if (chemicals.length != 1) {
            $("#prefix").val('').attr('disabled', false);
            $("#name").val('').attr('disabled', false);
            $("#inchi").val('').attr('disabled', false);
            $("#smiles").val('').attr('disabled', false);
            $("#pubchem").val('').attr('disabled', false);
            $("#density").val('').attr('disabled', false);
            $("#melting_point").val('').attr('disabled', false);
            $("#boiling_point").val('').attr('disabled', false);
            $("#haz_stats").val('').attr('disabled', false);
            $("#prec_stats").val('').attr('disabled', false);
            $("#un_number").val('').attr('disabled', false);
            $("#un_proper_shipping_name").val('').attr('disabled', false);
            $("#dg_class").val('').attr('disabled', false);
            $("#packing_group").val('').attr('disabled', false);
            $("#schedule").val('').attr('disabled', false);
        }
    }
}); //autocomplete ends