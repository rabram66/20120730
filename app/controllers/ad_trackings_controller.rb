class AdTrackingsController < ApplicationController
  # GET /ad_trackings
  # GET /ad_trackings.json
  def index
    @ad_trackings = AdTracking.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ad_trackings }
    end
  end

  # GET /ad_trackings/1
  # GET /ad_trackings/1.json
  def show
    @ad_tracking = AdTracking.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ad_tracking }
    end
  end

  # GET /ad_trackings/new
  # GET /ad_trackings/new.json
  def new
    @ad_tracking = AdTracking.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ad_tracking }
    end
  end

  # GET /ad_trackings/1/edit
  def edit
    @ad_tracking = AdTracking.find(params[:id])
  end

  # POST /ad_trackings
  # POST /ad_trackings.json
  def create
    @ad_tracking = AdTracking.new(params[:ad_tracking])

    respond_to do |format|
      if @ad_tracking.save
        format.html { redirect_to @ad_tracking, notice: 'Ad tracking was successfully created.' }
        format.json { render json: @ad_tracking, status: :created, location: @ad_tracking }
      else
        format.html { render action: "new" }
        format.json { render json: @ad_tracking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ad_trackings/1
  # PUT /ad_trackings/1.json
  def update
    @ad_tracking = AdTracking.find(params[:id])

    respond_to do |format|
      if @ad_tracking.update_attributes(params[:ad_tracking])
        format.html { redirect_to @ad_tracking, notice: 'Ad tracking was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @ad_tracking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ad_trackings/1
  # DELETE /ad_trackings/1.json
  def destroy
    @ad_tracking = AdTracking.find(params[:id])
    @ad_tracking.destroy

    respond_to do |format|
      format.html { redirect_to ad_trackings_url }
      format.json { head :ok }
    end
  end
end
