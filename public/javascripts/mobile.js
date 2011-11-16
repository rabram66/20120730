setLatLng = function(position) {
  $('#lat').val(position.coords.latitude);
  $('#lng').val(position.coords.longitude);
};

$(function() {
  window.navigator.geolocation.getCurrentPosition(setLatLng);
});

