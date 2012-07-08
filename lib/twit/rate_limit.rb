module Twit
  
  class RateLimit

    attr_reader :api_class, :limit, :remaining, :reset_time

    def initialize(attrs={})
      attrs.each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end
    
    def exceeded?
      Time.now < Time.at(reset_time) && remaining == 0
    end

    def to_hash
      {
        :api_class  => api_class,
        :limit      => limit,
        :remaining  => remaining,
        :reset_time => reset_time
      }
    end
    
  end
  
end
