$(document).ready(function() {
  
  // Automatic search on location category select
  if ($('#place_search #types').length) {
    $('#place_search #types').change( function() {
      $('#place_search').submit();
    });
  }
  
  if ($('#places-list').length) {
    $('#show-more-places').click(function() {
      $('#show-more-places').hide();
      $('#places-list div.expanded').fadeIn();
      $('#show-less-places').show();
    });
    $('#show-less-places').click(function() {
      $('#show-less-places').hide();
      $('#places-list div.expanded').fadeOut();
      $('#show-more-places').show();
    });
  }
  
  // Toggle Directions display
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
  
  if ($('.fancybox').length) $('.fancybox').fancybox();
})