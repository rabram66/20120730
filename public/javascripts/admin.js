$(document).ready( function() {
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
