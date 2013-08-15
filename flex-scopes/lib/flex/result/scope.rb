module Flex
  class Result
    module Scope

      def get_docs
        return self if variables[:raw_result]
        respond_to?(:collection) ? collection : self
      end

    end
  end
end
