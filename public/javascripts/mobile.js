setLatLng = function(position) {
  $('#lat').val(position.coords.latitude);
  $('#lng').val(position.coords.longitude);
  // $.mobile.loadPage( '/mobile/list?'+$('form#search_form').serialize()+"&commit=Use+My+Location", { showLoadMsg: false } ); // preload the current location results
};

showCategory = function(event) {
  var category = $(this).text().toLowerCase();
  $('ul#locations-list > li').hide();
  $('ul#locations-list > li.'+category).show();
}

$(function() {
  window.navigator.geolocation.getCurrentPosition(setLatLng); // set lat-lng to current location
  $('#searchTextField').click(function() {$(this).val('');});  // clear search field of prompt text
  $('ul#category-selector > li').click( showCategory );
  $('ul#category-selector > li:first a').click();
});

