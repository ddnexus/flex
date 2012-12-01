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

    end
  end
end
