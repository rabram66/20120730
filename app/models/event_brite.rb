class EventBrite

  include Address

  EVENT_SEARCH_URL = "https://www.eventbrite.com/json/event_search?app_key=#{Rails.application.config.app.eventbrite_app_key}&latitude=%s&longitude=%s&within=%s"
  EVENT_GET_URL    = "https://www.eventbrite.com/json/event_get?app_key=#{Rails.application.config.app.eventbrite_app_key}&id=%s"
  ID_PREFIX        = 'EB'

  attr_reader :id, :name, :description, :address, :city, :state, 
              :latitude, :longitude, :url, 
              :start_date, :end_date, :venue, :category

  def initialize(attrs={})
    attrs.each do |k,v|
      v = v.blank? ? nil : v
      instance_variable_set("@#{k}", v)
    end
  end

  # Event comptability
  def flyer_url
  end
  def tweets
    []
  end

  class << self
    def geosearch(coordinates, radius=2, count=10)
      api(EVENT_SEARCH_URL, coordinates.first, coordinates.last, radius) do |response|
        if response['events'].present?
          response['events'][1,count].map do |result| # Skip "summary" element
            transform result['event']
          end
        else
          []
        end
      end
    end
    
    def find_by_id(id)
      id.gsub!(/^#{ID_PREFIX}/,'')
      api(EVENT_GET_URL, id) do |response|
        if response['event'].present?
          transform response['event']
        end
      end
    end

    private

    def api(url, *args)
      url = format(url, *args)
      begin
        Rails.logger.info("EventBrite fetch: #{url}")
        response = RestClient.get(url)
        yield ActiveSupport::JSON.decode(response)
      rescue RestClient::Exception => e
        # HoptoadNotifier.notify e, :error_message => "EventBrite API failure: (#{e}) #{url}"
        Rails.logger.info("EventBrite API failure from #{`hostname`.strip}: (#{e}) #{url}: #{e.http_body}")
        nil
      end
    end

    def transform(result)
      hash = {
        :id        => "#{ID_PREFIX}#{result['id']}",
        :name      => result['title'],
        :category  => result['category'],
        :url       => result['url']
      }
      unless result['venue'].blank?
        res = result['venue']
        hash[:address]   = res['address']
        hash[:city]      = res['city']
        hash[:state]     = res['region']
        hash[:latitude]  = res['latitude']
        hash[:longitude] = res['longitude']
        hash[:venue]     = res['name']
      end
      hash[:start_date] = DateTime.parse( result['start_date'] ) unless result['start_date'].blank?
      hash[:end_date]   = DateTime.parse( result['end_date'] ) unless result['end_date'].blank?
      EventBrite.new( hash )
    end

  end

end