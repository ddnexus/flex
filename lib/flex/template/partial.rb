module Flex
  class Template
    class Partial

      include Base

      def initialize(data)
        @data       = data
        tags        = Tags.new
        stringified = tags.stringify(data)
        @partials, @tags = tags.map(&:name).partition{|n| n.to_s =~ /^_/}
        @variables  = tags.variables
        instance_eval <<-ruby, __FILE__, __LINE__
          def interpolate(main_vars=Variables.new, vars={})
            sym_vars = {}
            vars.each{|k,v| sym_vars[k.to_sym] = v} # so you can pass the rails params hash
            vars = process_vars main_vars.deep_merge(@variables, sym_vars)
            #{stringified}
          end
        ruby
      end

      def to_flex(name=nil)
        {name.to_s => @data}.to_yaml
      end

    end
  end
end
