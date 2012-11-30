module Flex
  module HttpClients
    class Base

      attr_accessor :options, :base_uri

      def initialize(base_uri='http://localhost:9200', options={})
        @options  = options
        @base_uri = base_uri
      end

    end
  end
end
