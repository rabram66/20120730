setLatLng = function(position) {
  $('#lat').val(position.coords.latitude);
  $('#lng').val(position.coords.longitude);
  $('#search_form').submit();
  // $.mobile.loadPage( '/mobile/list?'+$('form#search_form').serialize()+"&commit=Use+My+Location", { showLoadMsg: false } ); // preload the current location results
};

showCategory = function(event) {
  var category = $(this).text().toLowerCase();
  $('ul#locations-list > li').hide();
  $('ul#locations-list > li.'+category).show();
};

setCurrentPosition = function(event) {
  event.preventDefault();
  window.navigator.geolocation.getCurrentPosition( setLatLng );
};

mobileMap = {
  createMarker: function( latlng, map ){
    return new google.maps.Marker( { position: latlng, map: map } );
  },
  createDynamicMap: function( latlng, elem, options ){
    var div = $(elem)[0];
    return new google.maps.Map( div, options );
  },
  showLocation: function( lat, lng, elem ){
    var latlng = new google.maps.LatLng( lat, lng );
    var map = this.createDynamicMap( latlng, elem );
    var marker1 = this.createMarker( latlng, map );  
  },

  showMapWithDirections: function(origin_lat, origin_lng, dest_lat, dest_lng, elem) {
    var directionsService = new google.maps.DirectionsService();
    var directionsDisplay = new google.maps.DirectionsRenderer();
    var origin = new google.maps.LatLng(origin_lat, origin_lng);
    var destination = new google.maps.LatLng(dest_lat, dest_lng);
    var mapOptions = {
      zoom:8,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      center: destination
    };
    var map = new google.maps.Map($(elem)[0], mapOptions);
    directionsDisplay.setMap(map);

    var request = {
      origin: origin,
      destination: destination,
      travelMode: google.maps.TravelMode.WALKING
    };

    directionsService.route(request, function(result, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        directionsDisplay.setDirections(result);
      }
    });
  }
};

toggleTwitterMention = function(from, to) {
  if (to.length != 0) {
    current.removeClass('current');
    to.addClass('current');
    current.hide();
    to.show();
  }
};

$('#mobile-content').live('pageinit', function(event) {
  if ( $('#searchTextField').length > 0 ) {
    $('#searchTextField').click( function() { $(this).val('');} );  // clear search field of prompt text
    var autocomplete = new google.maps.places.Autocomplete( $('#searchTextField')[0] );
  }
  var input = document.getElementById('searchTextField');
  var autocomplete = new google.maps.places.Autocomplete(input);
  $('ul#category-selector > li').click( showCategory );
  $('ul#category-selector > li:first a').click();
  if ( $('#mobile-map').length > 0 ) {
    mobileMap.showMapWithDirections( $('#origin_lat').val(), $('#origin_lng').val(), $('#lat').val(), $('#lng').val(), $('#mobile-map') );
  }
  $('#use_my_location').click( setCurrentPosition );
  if ( $('#mobile-twitter-mentions').length > 0 ) {
    $('li.mobile-twitter-mention:first').show().addClass('current');
    $('#prev-tweet').click( function(event) {
      current = $('li.mobile-twitter-mention.current');
      toggleTwitterMention(current, current.prev());
    });
    $('#next-tweet').click( function(event) {
      current = $('li.mobile-twitter-mention.current');
      toggleTwitterMention(current, current.next());
    });
  }
});