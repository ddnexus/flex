module Flex
  class Template
    class Partial

      include Base

      attr_reader :name

      def initialize(data)
        @data       = data
        tags        = Tags.new
        stringified = tags.stringify(data)
        @partials, @tags = tags.partial_and_tag_names
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

      def setup(name=nil)
        @name = name
        self
      end

      def to_source
        {@name.to_s => @data}.to_yaml
      end

    end
  end
end
