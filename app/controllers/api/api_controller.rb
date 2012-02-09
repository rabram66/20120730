module Api
  class ApiController < ApplicationController
    def index
      render :text => 'eat more chicken'
    end
  end
end