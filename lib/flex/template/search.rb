module Flex
  class Template
    class Search < Template

      def initialize(data, vars=nil)
        super('GET', "/<<index>>/<<type>>/_search", data, vars)
      end

      def to_a(*vars)
        a = super
        2.times{ a.delete_at 0 }
        a
      end

      def to_msearch(*vars)
        vars   = Vars.new(*vars)
        int    = interpolate(vars, strict=true)
        header = {}
        header[:index] = int[:vars][:index] if int[:vars][:index]
        header[:type]  = int[:vars][:type]  if int[:vars][:type]
        [:search_type, :preferences, :routing].each do |k|
          header[k] = int[:vars][k] if int[:vars][k] || int[:vars][:params] && int[:vars][:params][k]
        end
        data, encoded = build_data(int, vars)
        "#{MultiJson.encode(header)}\n#{encoded}\n"
      end

    end
  end
end
