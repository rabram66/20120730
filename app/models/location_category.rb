class LocationCategory
  
  attr_accessor :name, :display_name, :types, :short_name
  
  def initialize(name, types=[], display_name=nil)
    @name = name
    @display_name = display_name || name
    @short_name = name.split('/').first
    @types = types
  end

  class << self
    def all 
      [EatDrink, ShopFind, Play, Spa]
    end
    
    def all_types
      all.map{ |lc| lc.types }.flatten
    end
    
    def find_by_name(name)
      all.detect{ |lc| lc.name =~ /#{name}/i}
    end
    
    def find_by_type(type)
      all.detect {|lc| lc.types.include? type}
    end

    def find_all_by_types(types)
      all.select {|lc| !(lc.types & types).empty?}
    end
  end

  EatDrink = LocationCategory.new(
    'Eat/Drink',
    %w(bar cafe restaurant food),
    'Eat & Drink'
  )

  ShopFind = LocationCategory.new(
    'Shop/Find',
    %w(clothing_store shoe_store convenience_store grocery_or_supermarket),
    'Shop'
  )
    
  Play = LocationCategory.new(
    'Play',
    %w(aquarium art_gallery bowling_alley casino gym movie_theater museum night_club park)
  )

  Spa = LocationCategory.new(
    'Spa',
    %w(beauty_salon spa)
  )


end