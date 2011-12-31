  var directionDisplay;
  var directionsService = new google.maps.DirectionsService();
  var map;
  var marker;
  var bussiness_address;
  function initialize() {
    directionsDisplay = new google.maps.DirectionsRenderer();
    var orig_latlng = new google.maps.LatLng($('#orig_lat').val(), $('#orig_lng').val());
    var latlng = new google.maps.LatLng($('#dest_lat').val(), $('#dest_lng').val());
    var myOptions = {
      zoom:10,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      center: bussiness_address
    };
    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    directionsDisplay.setMap(map);
    directionsDisplay.setPanel(document.getElementById('directions-panel-detail'));
              
    var request = {
      origin: orig_latlng,
      destination: latlng,
      travelMode: google.maps.DirectionsTravelMode.WALKING
    };
    directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        directionsDisplay.setDirections(response);
      }
  });
}

google.maps.event.addDomListener(window, 'load', initialize);