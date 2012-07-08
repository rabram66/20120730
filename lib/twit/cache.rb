module Twit
  class Cache
    
    # KEY_TEMPLATES = {
    #   :rate_limit_status => "twitter:rate_limit:%s", # rate limit class
    #   :user_status => "twitter:status:%s"            # screen name
    #   :mentions => "twitter:mentions:%s"             # screen name
    # }
    
    attr_reader :store
    
    def initialize(store)
      @store
    end

    class << self
      def key(type, *args)
      end
    end
  end
end