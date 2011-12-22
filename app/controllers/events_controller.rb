class EventsController < ApplicationController
  
  respond_to :html, :xml, :json, :js
  load_and_authorize_resource
  
  # GET /events
  def index
    respond_with @events
  end

  # GET /events/1
  def show
    respond_with @show
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
end
