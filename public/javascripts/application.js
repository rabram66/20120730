$(document).ready(function() {

  if ($('#mentions-panel').length || $('#deal-panel').length) {
    $("#direction_id").live('click', function() {
      if ($('#mentions-panel').css("display") != "none") {
        $("#direction_id").text("Tweets");
        $("#deal-panel").hide();
        $("#mentions-panel").hide();
        $("#directions-sidebar").show();            
      } else {
        $("#direction_id").text("Directions");
        $("#deal-panel").show();
        $("#mentions-panel").show();
        $("#directions-sidebar").hide();
      }
      return false;
    });
  } else {
    $("#directions-sidebar").show();
    $("#get-directions-link").hide();
  }

    // TODO: Why implement form submit this way? to prevent double-post?
    $(".actions input[type='button']").live('click', function() {
        $(this).attr("disabled","true");
        document.location_name.submit();
    })
  
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
    
    $('#mentions-panel').pajinate({
      items_per_page: 4,
      num_page_links_to_display: 2,
      show_first_last: false,
      nav_label_prev: '&lang;',
      nav_label_next: '&rang;'
    });
       
})