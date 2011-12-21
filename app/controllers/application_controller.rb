class ApplicationController < ActionController::Base
  protect_from_forgery
  
  has_mobile_fu

  def role
    if ['places', 'devise/sessions', 'devise/registrations', 'devise/passwords'].include? params[:controller]
      # do nothing; no restrictions
    else
      unless current_user.blank?
        permission = "access denied"
        if current_user.role? :admin
          permission = "OK"
        elsif current_user.role? :promoter
          permission = params["controller"] == 'events' ? "OK" : "access denied"
        end
        redirect_to root_url, :notice => permission if permission.eql?("access denied")
      else
        redirect_to root_url
      end
    end
  end
end
