$('#mobile-map').live('pageinit', function(event) {
  mapWidth = screen.width;
  mapHeight = screen.height;

  //Orientation
  var supportsOrientationChange = "onorientationchange" in window, 
    orientationEvent = supportsOrientationChange ? "orientationchange" : "resize";
    
  $(window).bind( orientationEvent, onOrientationChange );
  function onOrientationChange(){
    switch( window.orientation ){
      //Portrait: normal
      case 0:
        break;
      //Landscape: clockwise
      case -90:
        break;
      //Landscape: counterclockwise
      case "180":
        break;
      //Portrait: upsidedown
      case "90":
        break;
    }
  }
  
  //GeoLocation
  var geo = navigator.geolocation;
  if( geo ){
    geo.getCurrentPosition( showLocation, mapError, { timeout: 5000, enableHighAccuracy: true } );
  }
  
  function createMarker( latlng, map ){
    return new google.maps.Marker( { position: latlng, map: map } );
  }
  
  function createDynamicMap( latlng ){
    var div = $("#mobile-map")[0];
    var options = { zoom: 14, center: latlng, mapTypeId: google.maps.MapTypeId.ROADMAP };
    return new google.maps.Map( div, options );
  }

  function showLocation( position ){
    var lat = position.coords.latitude;
    var lng = position.coords.longitude;
    var latlng = new google.maps.LatLng( lat, lng );
    
    var map = createDynamicMap( latlng );
    var marker1 = createMarker( latlng, map );  
  }

  function mapError( e ){
    var error;
    switch( e.code ){
      case 1: 
        error = "Permission Denied.\n\n Please turn on Geo Location by going to Settings > Location Services > Safari";
      break;
      case 2: 
        error = "Network or Satellites Down";
      break;
      case 3: 
        error = "GeoLocation timed out";
      break;
      case 0: 
        error = "Other Error";
      break;
    }
    $("#mobile-map").html( error );
  }
});