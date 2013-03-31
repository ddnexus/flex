module Flex
  class Template
    module Common

      attr_reader :name, :partials, :tags, :data

      def setup(host_flex, name=nil, *vars)
        @host_flex   = host_flex
        @name        = name
        @source_vars = Vars.new(*vars) if is_a?(Flex::Template)
        self
      end

      def interpolate_partials(vars)
        @partials.each do |name|
          val = vars[name]
          next if Prunable::VALUES.include?(val)
          vars[name] = case val
                       when Array
                         val.map {|v| @host_flex.partials[name].interpolate(vars, v)}
                       # other partial name (usable as a conditional output)
                       when Symbol
                         @host_flex.partials[val].interpolate(vars, vars[val])
                       # a partial object
                       when Template::Partial
                         val.interpolate(vars)
                       # on-the-fly partial creation (an empty string would prune it before)
                       when String
                         Template::Partial.new(val).interpolate(vars)
                       # switch to include the partial (a false value would prune it before)
                       when TrueClass
                         @host_flex.partials[name].interpolate(vars)
                       else
                         @host_flex.partials[name].interpolate(vars, val)
                       end
        end
        vars
      end

    end
  end
end
