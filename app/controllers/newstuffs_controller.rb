class NewstuffsController < ApplicationController
  # GET /newstuffs
  # GET /newstuffs.xml
  def index
    @newstuffs = Newstuff.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @newstuffs }
    end
  end

  # GET /newstuffs/1
  # GET /newstuffs/1.xml
  def show
    @newstuff = Newstuff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @newstuff }
    end
  end

  # GET /newstuffs/new
  # GET /newstuffs/new.xml
  def new
    @newstuff = Newstuff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @newstuff }
    end
  end

  # GET /newstuffs/1/edit
  def edit
    @newstuff = Newstuff.find(params[:id])
  end

  # POST /newstuffs
  # POST /newstuffs.xml
  def create
    @newstuff = Newstuff.new(params[:newstuff])

    respond_to do |format|
      if @newstuff.save
        format.html { redirect_to(@newstuff, :notice => 'Newstuff was successfully created.') }
        format.xml  { render :xml => @newstuff, :status => :created, :location => @newstuff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @newstuff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /newstuffs/1
  # PUT /newstuffs/1.xml
  def update
    @newstuff = Newstuff.find(params[:id])

    respond_to do |format|
      if @newstuff.update_attributes(params[:newstuff])
        format.html { redirect_to(@newstuff, :notice => 'Newstuff was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @newstuff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /newstuffs/1
  # DELETE /newstuffs/1.xml
  def destroy
    @newstuff = Newstuff.find(params[:id])
    @newstuff.destroy

    respond_to do |format|
      format.html { redirect_to(newstuffs_url) }
      format.xml  { head :ok }
    end
  end
end
