module Flex
  module Structure
    module Symbolize

      def symbolize(obj)
        case obj
        when Flex::Structure::Hash, Flex::Structure::Array
          obj
        when ::Hash
          h = Structure::Hash.new
          obj.each do |k,v|
            h[k.to_sym] = symbolize(v)
          end
          h
        when ::Array
          a = Structure::Array.new
          obj.each{|i| a << i}
          a
        else
          obj
        end
      end

    end
  end
end
