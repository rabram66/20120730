class EventsController < ApplicationController
  
  respond_to :html, :xml, :json, :js
  before_filter :load_event, :only => [:show, :ical]
  load_and_authorize_resource :except => [:show, :ical]
  
  # GET /events
  def index
    respond_with @events
  end

  # GET /events/1
  def show
    respond_with @event
  end

  # GET /events/new
  def new
    respond_with @event
  end

  # GET /events/1/edit
  def edit
    respond_with @event
  end

  # POST /events
  def create
    if @event.save
      flash[:notice] = "Successfully created event."
    end
    respond_with @event
  end

  # PUT /events/1
  def update
    if @event.update_attributes(params[:event])
      flash[:notice] = "Successfully updated event."
    end
    respond_with @event
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    flash[:notice] = "Successfully destroyed event."
    respond_with @event
  end
  
  def ical
    render :text => to_ical(@event), :header => {'Content-Type'=>'text/calendar'}, :layout => false
  end

  private

  def load_event
    @event = Event.find(params[:id])
  end

  def to_ical(event)
    RiCal.Calendar do |cal|
      cal.event do |cal_event|
        cal_event.summary = event.name
        cal_event.dtstart = event.start_date if event.start_date
        cal_event.dtend = event.end_date if event.end_date
        cal_event.location = event.full_address
        cal_event.url = event_url(event.id)
      end
    end
  end
  
    
end
