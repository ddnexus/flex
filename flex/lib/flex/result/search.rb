module Flex
  class Result
    module Search

      # extend if result comes from a search url
      def self.should_extend?(result)
        result.response.url =~ /\b_m?search\b/ && result['hits']
      end

      # extend the hits results on extended
      def self.extended(result)
        result['hits']['hits'].each { |h| h.extend(Document) }
        result['hits']['hits'].extend Struct::Paginable
        result['hits']['hits'].setup(result['hits']['total'], result.variables)
      end

      def collection
        self['hits']['hits']
      end
      alias_method :documents, :collection

      def facets
        self['facets']
      end

    end
  end
end
