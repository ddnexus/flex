module Flex
  module ClassProxy
    class Loader < Base

      include Modules::Loader

      def initialize(base)
        super
        @sources   = []
        @templates = {}
        @partials  = {}
      end

    end
  end
end
