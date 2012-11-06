module Flex
  class Result
    module MultiGet

      # extend if result comes from a search url
      def self.should_extend?(result)
        result.response.url =~ /\b_mget\b/ && result['docs']
      end

      # extend the hits results on extended
      def self.extended(result)
        result['docs'].each { |h| h.extend(Document) }
      end

      def docs
        self['docs']
      end

    end
  end
end
