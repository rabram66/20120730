# A grouping of search areas
class City

  attr_reader :name, :areas

  def initialize(name, areas)
    @name = name.titleize
    @areas = areas
  end

  class << self
    def find(name)
      case name 
      when /atlanta/i
        areas = [
          ["Ansley Park", "Ansley Park, Atlanta, GA"],
          ["Inman Park", "Inman Park, Atlanta, GA"],
          ["Midtown", "Midtown, Atlanta, GA"],
          ["Downtown", "Downtown, Atlanta, GA"],
          ["VA Highland", "Virginia Highland, Atlanta, GA"],
          ["Poncey Highland", "Poncey-Highland, Atlanta, GA"],
          ["Little Five Points", "Little Five Points, Moreland Avenue Northeast, Atlanta, GA"],
          ["Castleberry Hill", "Castleberry Hill, Atlanta, GA"],
          ["Oakland Park", "Oakland Park, Memorial Drive Southeast, Atlanta, GA"]
        ]
        new(name, areas.map{ |area| Area.new(area.first, area.last) })
      end
    end
  end
end