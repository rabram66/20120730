module Api
  class ApiController < ApplicationController
    layout false
    respond_to :json
    
    def index
      respond_with( @links = {:places => api_places_url} )
    end
    
    def twitter_profile
      res = Twitter.user params[:twitter_name]
      respond_with({:profile_image_url => res.profile_image_url, :description => res.description})
    end
  end
end