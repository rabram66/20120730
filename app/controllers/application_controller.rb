class ApplicationController < ActionController::Base
  
  include ApplicationHelper
  
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => 'Access Denied'
  end

  protected

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
