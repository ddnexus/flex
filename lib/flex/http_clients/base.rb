module Flex
  module HttpClients
    class Base

      attr_accessor :options, :base_uri, :raise_proc

      def initialize(base_uri='http://localhost:9200', options={})
        @options    = options
        @base_uri   = base_uri
        @raise_proc = proc{|response| response.status >= 400}
      end

    end
  end
end
