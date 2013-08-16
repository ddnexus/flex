module Flex
  module ActiveModel
    module Inspection

      def inspect
        descriptions   = [%(_id: #{@_id.inspect}), %(_version: #{@_version})]
        all_attributes = if respond_to?(:raw_document)
                           reader_keys = raw_document.send(:readers).keys.map(&:to_s)
                           # we send() the readers, so they will reflect an eventual overriding
                           Hash[ reader_keys.map{ |k| [k, send(k)] } ].merge(attributes)
                         else
                           attributes
                         end
        descriptions << all_attributes.sort.map { |key, value| "#{key}: #{value.inspect}" }
        separator = " " unless descriptions.empty?
        "#<#{self.class.name}#{separator}#{descriptions.join(", ")}>"
      end

    end
  end
end
