class Subdomain  
  def self.matches?(request)  
    request.subdomain == 'preview'  
  end  
end