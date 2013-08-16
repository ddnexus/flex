module Flex
  class Template
    class Partial

      include Common

      def initialize(data)
        @data            = data
        tags             = Tags.new
        stringified      = tags.stringify(data)
        @partials, @tags = tags.partial_and_tag_names
        @tags_variables  = tags.variables
        instance_eval <<-ruby, __FILE__, __LINE__
          def interpolate(vars={}, partial_assigned_vars={})
            vars = Vars.new(vars, @tags_variables, partial_assigned_vars)
            vars = interpolate_partials(vars)
            #{stringified}
          end
        ruby
      end

      def to_source
        {@name.to_s => @data}.to_yaml
      end

    end
  end
end
