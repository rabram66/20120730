$(document).ready(function() {
    
    $("#direction_id").live('click', function() {
        if ($('#mentions_id').css("display") != "none") {
            $("#direction_id").text("Tweets");
            $("#mentions_id").hide();
            $("#directions-panel").show();            
        }
        else {
            $("#direction_id").text("Directions");
            $("#mentions_id").show();
            $("#directions-panel").hide();
        }
        return false;
    })

    // TODO: Why implement form submit this way? to prevent double-post?
    $(".actions input[type='button']").live('click', function() {
        $(this).attr("disabled","true");
        document.location_name.submit();
    })

    $("#location_facebook_page_id").tokenInput("/load_page", {
        crossDomain: false,
        prePopulate: $("#location_facebook_page_id").data("pre"),
        theme: "facebook"
    });
  
  
    $('.delete_location').live('click', function() {
        var id = $(this).attr("id");
        $(".img_" + id).show();
        jQuery.ajax({
            data:{},
            dataType: "text",
            type:'get',
            url:'/delete_place/' + id,
            success: function(text) {
                $(".img_" + id).hide();
                if (text == "1"){                      
                    $("."+ id).hide('slow');
                }
                else if (text == "2"){
                    $(".error_" + id).html("can't delete this place");
                }            
            }
        })
        return false;
    })
    
    $("#route").click(function(){
        calcRoute();
    })
    
    
    $("#advertise_address_name").live('change', function() {
        $("#ajax_load").show();
        $('#advertise_business_name').load("/load_business/" + $(this).val().replace(" ","%20").replace(", ",",%20")+ "?category=" + $("#advertise_business_type").val(), function() {
            $("#ajax_load").hide();
        });
    //$("#ajax_load").hide();
    }) 
  
    $('#mentions-container').pajinate({
      items_per_page: 4
    });
       
})