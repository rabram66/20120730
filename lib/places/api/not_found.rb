module Places
  module Api
    class NotFound < Exception
      attr_reader :reference
      def initialize(reference=nil)
        @reference = reference
      end
    end
  end
end