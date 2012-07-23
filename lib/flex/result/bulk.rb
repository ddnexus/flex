module Flex
  class Result
    module Bulk

      # extend if result comes from a bulk url
      def self.should_extend?(result)
        result.response.url =~ /\b_bulk\b/
      end

      def failed
        self['items'].reject{|i| i['index']['ok']}
      end

      def successful
        self['items'].select{|i| i['index']['ok']}
      end

    end
  end
end
