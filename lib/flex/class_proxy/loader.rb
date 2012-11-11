module Flex
  module ClassProxy
    class Loader < Base

      include Modules::Loader

      def initialize(base, vars={})
        super
        @sources   = []
        @templates = {}
        @partials  = {}
      end

    end
  end
end
