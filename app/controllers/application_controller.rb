class ApplicationController < ActionController::Base
  
  include ApplicationHelper
  
  before_filter :tablet_device_fallback

  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => 'Access Denied'
  end

  protected

  def tablet_device_fallback
    request.format = :html if request.format == :tablet
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
