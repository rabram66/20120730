$(document).ready(function() {
    
    $("#location_name").tokenInput("/load_page", {
    crossDomain: false,
    prePopulate: $("#location_name").data("pre"),
    theme: "facebook"
  });
  
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
})