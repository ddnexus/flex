module Flex
  class Template
    class Partial

      attr_reader :name

      def initialize(data)
        @data       = data
        tags        = Tags.new
        stringified = tags.stringify(data)
        @partials, @tags = tags.partial_and_tag_names
        @variables  = tags.variables
        instance_eval <<-ruby, __FILE__, __LINE__
          def interpolate(main_vars={}, vars={})
            vars = Variables.new(main_vars, @variables, vars)
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
