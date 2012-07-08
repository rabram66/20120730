module Twit

  USER_TIMELINE_URL = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=%s&count=%d&include_entities=1"
  USER_PROFILE_URL = "https://api.twitter.com/1/users/search.json?q=%s"

  module Api
    
    class Timeline
      attr_reader :screen_name
      def initialize(screen_name)
        @screen_name = screen_name
      end
    end

    class << self

      def latest(screen_name, count=1)
        api(USER_TIMELINE_URL, screen_name, count) do |response|
          if count == 1
            result = response.first
            transform_result( result ) if result
          else
            response.map { |result| transform_result( result ) }
          end
        end
      end

      def profile(screen_name)
        api(USER_PROFILE_URL, screen_name) do |response|
          puts response
        end
      end

      private

      def api(url, *args)
        url = format(url, *args)
        begin
          Rails.logger.info("Twitter fetch: #{url}")
          response = RestClient.get(url)
          write_ratelimit(response)
          yield ActiveSupport::JSON.decode(response)
        rescue RestClient::Exception => e
          # HoptoadNotifier.notify e, :error_message => "Twitter API failure: (#{e}) #{url}"
          Rails.logger.info("Twitter API failure from #{`hostname`.strip}: (#{e}) #{url}: #{e.http_body}")
          nil
        end
      end

    end

  end

end