$(document).ready( function() {
  if ($('#map_canvas').length) {

    var directionDisplay;
    var directionsService = new google.maps.DirectionsService();
    var map;
    var marker;

    function loadMapAndDirections() {

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

    $("#route").click(function(){
      calcRoute();
    });

  }
});

// google.maps.event.addDomListener(window, 'load', initialize);