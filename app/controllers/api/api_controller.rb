module Api
  class ApiController < ApplicationController
    layout false
    respond_to :json
    
    def index
      respond_with( @links = {:places => api_places_url} )
    end
  end
end