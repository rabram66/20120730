module Api
  class PlacesController < ApiController
    
    def index
      set_coordinates
      respond_with( @places = PlaceLoader.near(@coordinates) )
    end
    
    private
    
    def set_coordinates
      @coordinates = (params[:lat] && params[:lng]) ? [params[:lat].to_f, params[:lng].to_f] : Rails.application.config.app.default_coordinates
    end

  end
end