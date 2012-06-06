class DealImporter
  
  attr_accessor :coordinates, :services, :radius

  def initialize( coordinates, options={})
    @coordinates = coordinates
    @radius = options[:radius] || 2 
    @services = options[:services] || %w(Deals::YipitApi Deals::MobileSpinachApi)
  end
  
  def import
    services.each do |service|
      result = service.constantize.geosearch(coordinates, radius)
      result.each do |r|
        Deal.create(r) unless Deal.find_by_provider_and_provider_id(r[:provider], r[:provider_id].to_s)
      end
    end
  end
end
