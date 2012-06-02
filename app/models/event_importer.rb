class EventImporter
  
  attr_accessor :coordinates, :radius, :count, :services

  def initialize( coordinates, options={})
    @coordinates = coordinates
    @radius = options[:radius] ||= 10
    @count = options[:count] || 10
    @services = options[:services] || ['EventBriteApi']
  end
  
  def import
    services.each do |service|
      result = service.constantize.geosearch(coordinates, radius, count)
      result.each do |r|
        Event.create(r) unless Event.find_by_source_and_id(r[:source], r[:source_id])
      end
    end
  end
end
  