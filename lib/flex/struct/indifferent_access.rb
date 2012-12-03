module Flex
  module Struct
    # allows to use both Symbol or String keys to access the same values in a Hash
    module IndifferentAccess

      def [](k)
        get_value(k)
      end

      def []=(k,v)
        # default to_s for storing new keys
        has_key?(k) ? super : super(k.to_s, v)
      end

      def to_hash
        self
      end

    private

      def get_value(k)
        val = fetch_val(k)
        case val
        when ::Hash
          val.extend IndifferentAccess
        when ::Array
          val.each {|v| v.extend IndifferentAccess if v.is_a?(Hash)}
        end
        val
      end

      def fetch_val(k)
        v = fetch(k, nil)
        return v unless v.nil?
        if k.is_a?(String)
          v = fetch(k.to_sym, nil)
          return v unless v.nil?
        end
        fetch(k.to_s, nil) if k.is_a?(Symbol)
      end

    end
  end
end
