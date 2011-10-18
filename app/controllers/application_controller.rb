class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :role
  
  def role    
    if (params[:controller].eql?("locations") && params[:action].eql?("index")) or 
        (params[:controller].eql?("locations") && params[:action].eql?("details")) or
        (params[:controller].eql?("locations") && params[:action].eql?("search")) or
        (params[:controller].eql?("devise/sessions")) or 
        (params[:controller].eql?("devise/registrations")) or 
        (params[:controller].eql?("devise/passwords"))
      # do nothing
    else
      unless current_user.blank?
        permision = "access denied"
        if current_user.role.eql? "Admin"
          permision = "OK" 
        elsif current_user.role.eql? "Promoter"
          permision = params["controller"].eql?("events") ? "OK" : "access denied"      
        elsif current_user.role.eql? "User"
          permision = params["controller"].eql?("locations") ? "OK" : "access denied"    
        end
        redirect_to "/" if permision.eql?("access denied")
      else
        redirect_to "/"
      end
    end
  end
end
