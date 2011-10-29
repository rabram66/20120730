$(document).ready(function() {

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
        $('#advertise_business_name').load("/load_business/" + $(this).val().replace(" ","%20").replace(", ",",%20"), function() {
            $("#ajax_load").hide();
        });
    //$("#ajax_load").hide();
    }) 
       
})