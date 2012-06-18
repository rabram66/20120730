window.twttr = (function (d,s,id) {
  var t, js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return; js=d.createElement(s); js.id=id;
  js.src="//platform.twitter.com/widgets.js"; fjs.parentNode.insertBefore(js, fjs);
  return window.twttr || (t = { _e: [], ready: function(f){ t._e.push(f) } });
}(document, "script", "twitter-wjs"));

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

$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }
    if (opts !== false) {
      data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
    }
  });
  return this;
};

$(document).ready(function() {
  
  // Directions.js
  var directionDisplay;
  var directionsService = new google.maps.DirectionsService();
  var map;
  var marker;

  function loadMapAndDirections() {

    if (!$('#map_canvas').length) return;

    var dest_latlng = new google.maps.LatLng($('#dest_lat').val(), $('#dest_lng').val());
    if($('#orig_lat').length) {
      var orig_latlng = new google.maps.LatLng($('#orig_lat').val(), $('#orig_lng').val());
    } else {
      var orig_latlng = dest_latlng;
    }

    var myOptions = {
      zoom:10,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      center: dest_latlng
    };

    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    
    if ($('#directions-panel-detail').length) {
      directionsDisplay = new google.maps.DirectionsRenderer();
      directionsDisplay.setMap(map);
      directionsDisplay.setPanel(document.getElementById('directions-panel-detail'));

      var request = {
        origin: orig_latlng,
        destination: dest_latlng,
        travelMode: google.maps.DirectionsTravelMode.WALKING
      };

      directionsService.route(request, function(response, status) {
        if (status == google.maps.DirectionsStatus.OK) {
          directionsDisplay.setDirections(response);
        }
      });
    }

  }

  loadMapAndDirections();

  function bindDirectionControls() {
    // Toggle Directions display
    if ($('#mentions-container').length) {
      $("#direction_id").on('click', function() {
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
  }
  
  // pjax
  $('a.pjax').pjax('#detail-content', {timeout: 10000});

  $(document)
    .on('pjax:start', function() { $('#loading').show().spin(); })
    .on('pjax:end',   function() {
      twttr.widgets.load(); // rebind tweet buttons
      loadMapAndDirections();
      bindDirectionControls();
      $('#loading').hide().spin(false);
    });

  // go button
  $('#search_button').click( function() {$('#place_search').submit()} );

  // location type (all, eat, shop, ...) tab handling
  $('#location_type_nav a.loc_type').click( function(event) {
    $('#location_type_nav li.active').removeClass('active');
    $('#place_search input#location_type').val(event.target.textContent);
    $('#place_search').submit();
  });

  var active_tab = '#location_type_nav li#nav' + $('#place_search input#location_type').val();
  $('#location_type_nav li').removeClass('active');
  $(active_tab).addClass('active');
  
  // deals and events toggles
  $('#show-deals, li#navDEALS a').click( function() {
    $('#deals-list').toggle();
    $('#show-deals').toggleClass('active')
  });

  $('#show-events, li#navEVENTS a').click( function() {
    $('#events-list').toggle();
    $('#show-events').toggleClass('active')
  });

  bindDirectionControls();

  if ($('.fancybox').length) $('.fancybox').fancybox();

  if ($('.tweet-this').length) {
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
});