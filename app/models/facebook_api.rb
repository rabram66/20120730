class FacebookApi

  FEED_URL = "http://www.facebook.com/feeds/page.php?format=json&id=%s"
  PAGE_URL = "http://graph.facebook.com/%s"

  class << self
    
    # Get the facebook ID (required for fetching the feed) from the page name
    def id_for_page(name)
      url = format(PAGE_URL, CGI.escape(name))
      begin
        response = RestClient.get( url )
        if response.code == 200
          result = ActiveSupport::JSON.decode(response) 
          result['id']
        else
          Rails.logger.error "Unable to retrieve Facebook ID for page: (#{response.code}) #{url}"
        end
      rescue RestClient::ResourceNotFound, MultiJson::DecodeError
        Rails.logger.error "Unable to retrieve Facebook ID for page: (404) #{url}"
        nil
      end
    end

    def feed(facebook_id,count=10)
      results = []
      begin
        facebook_id = id_for_page(facebook_id) unless facebook_id =~ /^\d+$/
      
        if facebook_id
          url = format(FEED_URL, CGI.escape(facebook_id)) 
          begin
            response = RestClient.get( url )
            begin
              result = ActiveSupport::JSON.decode(response.body)
              if result['link'].nil? || result['entries'].nil?
                Rails.logger.error "Unexpected response body: (#{result}) #{url}"
              else
                results = result['entries'].reject{|e| e['title'].strip.blank?}[0,count].map do |entry|
                  yield entry
                end
              end
            rescue MultiJson::DecodeError => e
              Rails.logger.error "Exception: #{e}: #{url}"
            end
          rescue RestClient::Exception => e
            Rails.logger.error "Unable to retrieve Facebook feed: (#{e}) #{url}"
          end
        end
      rescue Errno::ETIMEDOUT, Errno::ECONNRESET
        Rails.logger.error "Connection error retrieving Facebook feed: (#{e}) #{url}"
      end
      results
    end

  end

end