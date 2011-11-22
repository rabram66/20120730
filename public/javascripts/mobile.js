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
  createDynamicMap: function( latlng, elem ){
    var div = $(elem)[0];
    var options = { zoom: 14, center: latlng, mapTypeId: google.maps.MapTypeId.ROADMAP };
    return new google.maps.Map( div, options );
  },
  showLocation: function( lat, lng, elem ){
    var latlng = new google.maps.LatLng( lat, lng );
    var map = this.createDynamicMap( latlng, elem );
    var marker1 = this.createMarker( latlng, map );  
  }
};

$('#mobile-content').live('pageinit', function(event) {
  $('#searchTextField').click( function() {$(this).val('');} );  // clear search field of prompt text
  $('ul#category-selector > li').click( showCategory );
  $('ul#category-selector > li:first a').click();
  if ( $('#mobile-map').length > 0 ) {
    mobileMap.showLocation( $('#lat').val(), $('#lng').val(), $('#mobile-map') );
  }
  $('#use_my_location').click( setCurrentPosition );
});