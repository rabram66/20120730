class UsersController < ApplicationController
  respond_to :html, :xml, :json, :js
  load_and_authorize_resource
  
  # GET /users
  def index
    respond_with @users
  end

  # GET /users/1
  def show
    respond_with @show
  end

  # GET /users/new
  def new
    respond_with @user
  end

  # GET /users/1/edit
  def edit
    respond_with @user
  end

  # POST /users
  def create
    if @user.save
      flash[:notice] = "Successfully created user."
    end
    respond_with @user
  end

  # PUT /users/1
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
    end
    respond_with @user
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    flash[:notice] = "Successfully destroyed user."
    respond_with @user
  end
end
