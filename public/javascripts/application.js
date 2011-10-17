$(document).ready(function() {
    $('.delete_location').live('click', function() {
        jQuery.ajax({
            data:{},
            dataType: "text",
            type:'get',
            url:'/delete_place/' + $(this).attr("id"),
            success: function(text) {                    
                if (text == "1"){                        
                    $(this).hide('slow');
                }
                else if (text == "2"){
                
                }            
            }
        })
        return false;
    })
})