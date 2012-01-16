module Jobs
  class TwitterStatusUpdate
    
    attr_accessor :twitter_names
    
    def initialize(locations=[])
      @twitter_names = locations.map(&:twitter_name)
    end
    
    def process
      twitter_names.each do |name|
        Tweet.user_status(name) unless name.blank?
      end
    end
    
  end
end