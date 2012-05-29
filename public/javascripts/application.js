function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}

function toDegrees(radians) {
  return radians * (180 / Math.PI);
}

/* Simple approximation */
function bounds(lat, lng, radius) {
  var R = 6371;  // earth radius in km
  var radius = 25; // km

  // southwest
  var sw_lat = lat - toDegrees(radius/R);
  var sw_lng = lng - toDegrees(radius/R/Math.cos(toRadians(lat)));

  // northeast
  var ne_lat = lat + toDegrees(radius/R);
  var ne_lng = lng + toDegrees(radius/R/Math.cos(toRadians(lat)));

  return new google.maps.LatLngBounds(
    new google.maps.LatLng(sw_lat, sw_lng), // southwest
    new google.maps.LatLng(ne_lat, ne_lng)  // northeast
  );
}

$(document).ready(function() {
  
  // pjax
  $('a.pjax').pjax('#detail-content', {timeout: 4000});

  $(document)
    .bind('pjax:start', function() { $('#loading').show() })
    .bind('pjax:end',   function() { $('#loading').hide() });

  // go button
  $('#search_button').click( function() {$('#place_search').submit()} );

  // location type (all, eat, shop, ...) tab handling
  $('#location_type_nav a').click( function(event) {
    $('#place_search input#location_type').val(event.target.textContent);
    $('#place_search').submit();
  });

  var active_tab = '#location_type_nav li#nav' + $('#place_search input#location_type').val();
  $('#location_type_nav li').removeClass('active');
  $(active_tab).addClass('active');
  
  // deals and events toggles
  $('#show-deals').click( function() {
    $('#deals-list').toggle();
    $('#show-deals').toggleClass('active')
  });

  $('#show-events').click( function() {
    $('#events-list').toggle();
    $('#show-events').toggleClass('active')
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

  // TODO: Move to separate admin.js
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