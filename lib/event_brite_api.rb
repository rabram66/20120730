class EventBriteApi

  EVENT_SEARCH_URL = "https://www.eventbrite.com/json/event_search?app_key=#{Rails.application.config.app.eventbrite_app_key}&latitude=%s&longitude=%s&within=%s"
  EVENT_GET_URL    = "https://www.eventbrite.com/json/event_get?app_key=#{Rails.application.config.app.eventbrite_app_key}&id=%s"

  class Sanitizer
    include ActionView::Helpers::SanitizeHelper

    def strip(html)
      strip_tags(html)
    end
  end

  @sanitizer = Sanitizer.new

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
    
    def find_by_source_id(id)
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
        Rails.logger.info("EventBriteApi fetch: #{url}")
        response = RestClient.get(url)
        yield ActiveSupport::JSON.decode(response)
      rescue RestClient::Exception => e
        # HoptoadNotifier.notify e, :error_message => "EventBriteApi failure: (#{e}) #{url}"
        Rails.logger.info("EventBriteApi failure from #{`hostname`.strip}: (#{e}) #{url}: #{e.http_body}")
        nil
      end
    end

    def transform(result)
      hash = {
        :name      => result['title'],
        :category  => result['category'].split(',').first,
        :url       => result['url'],
        :description => @sanitizer.strip(result['description']),
        :thumbnail_url => result['logo'] || "/images/event_icon.jpg"
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
      
      hash[:source] = 'EventBrite'
      hash[:source_id] = result['id'].to_s
      hash[:rank] = 10
      
      hash
    end

  end

end