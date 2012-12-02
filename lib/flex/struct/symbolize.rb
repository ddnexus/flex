module Flex
  module Struct
    module Symbolize

      def symbolize(obj)
        case obj
        when Flex::Struct::Hash, Flex::Struct::Array
          obj
        when ::Hash
          h = Struct::Hash.new
          obj.each do |k,v|
            h[k.to_sym] = symbolize(v)
          end
          h
        when ::Array
          a = Struct::Array.new
          obj.each{|i| a << i}
          a
        else
          obj
        end
      end

    end
  end
end
