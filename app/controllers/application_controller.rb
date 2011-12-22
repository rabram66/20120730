class ApplicationController < ActionController::Base
  protect_from_forgery
  
  has_mobile_fu

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => 'Access Denied'
  end

end
