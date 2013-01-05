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
        result['docs'].extend Collection
        result['docs'].setup(result['docs'].size, result.variables)
      end

      def docs
        self['docs']
      end
      alias_method :collection, :docs

    end
  end
end
