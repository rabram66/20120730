setLatLng = function(position) {
  $('#lat').val(position.coords.latitude);
  $('#lng').val(position.coords.longitude);
};

$(function() {
  window.navigator.geolocation.getCurrentPosition(setLatLng); // set lat-lng to current location
  $('#searchTextField').click(function() {$(this).val('');});  // clear search field of prompt text
});

