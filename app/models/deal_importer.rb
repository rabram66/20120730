class DealImporter
  
  attr_accessor :coordinates, :services

  def initialize( coordinates, options={})
    @coordinates = coordinates
    @services = options[:services] || %w(YipitApi MobileSpinachApi)
  end
  
  def import
    services.each do |service|
      result = service.constantize.geosearch(coordinates)
      result.each do |r|
        Deal.create(r) unless Deal.find_by_source_and_id(r[:source], r[:source_id])
      end
    end
  end
end
