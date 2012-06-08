module Api
  class ApiController < ApplicationController
    layout false
    respond_to :json
    
    def index
      respond_with( @links = {:places => api_places_url} )
    end
    
    def twitter_profile
      begin 
        res = Twitter.user params[:twitter_name]
        respond_with({:profile_image_url => res.profile_image_url, :description => res.description})
      rescue Twitter::NotFound
        Rails.logger.info("Twitter profile for '#{params[:twitter_name]}' not found.")
      end
    end
  end
end