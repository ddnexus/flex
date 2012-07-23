module Flex
  class Result
    module SourceSearch

      # extend if result comes from a search url and does not contain an empty fields param (no _source))
      def self.should_extend?(result)
        result.response.url =~ /\b_m?search\b/ &&
            !result['hits']['hits'].empty? && result['hits']['hits'].first.has_key?('_source')
      end

      # extend the hits results on extended
      def self.extended(result)
        result['hits']['hits'].each { |h| h.extend(SourceDocument) }
      end

      # experimental
      # returns an array of document mapped objects
      def mapped_collection
        @mapped_collection ||= begin
                               docs = self['hits']['hits'].map do |h|
                                        raise NameError, "no '_source' found in hit #{h.inspect} " \
                                              unless h.respond_to(:to_mapped)
                                        h.to_mapped
                                      end
                               docs.extend Collection
                               docs.setup(self['hits']['total'], variables)
                             end
      end

    end
  end
end
