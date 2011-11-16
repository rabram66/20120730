module LocationCategory

  class EatDrink
    class << self
      def types
        %w(bar cafe restaurant food)
      end
    end
  end

  class RelaxCare
    class << self
      def types
        %w(aquarium art_gallery beauty_salon bowling_alley casino gym movie_theater museum night_club park spa)
      end
    end
  end

  class ShopFind
    class << self
      def types
        %w(clothing_store shoe_store convenience_store)
      end
    end
  end

end