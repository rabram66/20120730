module Api
  class EventsController < ApiController
    
    def index
      set_coordinates
      respond_with( @events = EventSet.upcoming_near(@coordinates) )
    end

    def show
      load_event
      respond_with @event
    end
    
    private

    def load_event
      @event = Event.find(params[:id])
    end
    
    def set_coordinates
      @coordinates = (params[:lat] && params[:lng]) ? [params[:lat].to_f, params[:lng].to_f] : Rails.application.config.app.default_coordinates
    end

  end
end