module Twitter

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

  end
end