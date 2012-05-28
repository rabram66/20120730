$(document).ready(function() {
  
  $('#show-deals').click( function() {
    $('#events-list').hide();
    $('#deals-list').show();
  });

  $('#show-events').click( function() {
    $('#deals-list').hide();
    $('#events-list').show();
  });

  // Toggle Directions display
  if ($('#mentions-container').length) {
    $("#direction_id").live('click', function() {
      if ($('#mentions-container').css("display") != "none") {
        $("#direction_id").text("Tweets");
        $("#mentions-container").hide();
        $("#directions-container").show();            
      } else {
        $("#direction_id").text("Directions");
        $("#mentions-container").show();
        $("#directions-container").hide();
      }
      return false;
    });
  } else {
    $("#directions-container").show();
    $("#direction_id").hide();
  }

  // TODO: Why implement form submit this way? to prevent double-post?
  $(".actions input[type='button']").live('click', function() {
      $(this).attr("disabled","true");
      document.location_name.submit();
  });
  
  $("#route").click(function(){
    calcRoute();
  });
  
  if ($('.fancybox').length) $('.fancybox').fancybox();

  if ($('#tweet-this').length) {
    twttr.ready(function (twttr) { // load twitter widget.js
       // bind events here
       twttr.events.bind('tweet', function(event) {
         if (event.target.parentElement.id == "favorite-this") {
           // invoke favorite callback
           $.post(window.location.pathname.replace("/details","/favorite"));
         }
       });
     });
  }
  
  if ($('#update-twitter-profile').length) {
    $('#update-twitter-profile').click(function(){
      $.get('/api/twitter_profile?twitter_name='+$('#location_twitter_name').val(), function(data) {
        if( data['profile_image_url'] ) {
          el = $('#location_profile_image_url');
          el.val(data['profile_image_url']);
        }
        if( data['description'] ) {
          el = $('#location_description');
          el.val(data['description']);
        }
      });
      return false;
    });
  }

});