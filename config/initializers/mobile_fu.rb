module ActionController
  module MobileFu
    module InstanceMethods
      def is_mobile_device?
        !!mobile_device && !is_device?('ipad')
      end
    end
  end
end