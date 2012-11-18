module Flex
  class Template

    class Prunable
      class << self
        def to_s; '' end
        alias_method :===, :==
      end
    end

    module Base

      def process_vars(vars)
        @partials.each do |name|
          next if vars[name].nil?
          raise ArgumentError, "Array expected as :#{name} (got #{vars[name].inspect})" \
                unless vars[name].is_a?(Array)
          vars[name] = vars[name].map {|v| @host_flex.partials[name].interpolate(@variables.deep_dup, v)}
        end
        vars[:index] = vars[:index].join(',') if vars[:index].is_a?(Array)
        vars[:type]  = vars[:type].join(',')  if vars[:type].is_a?(Array)
        if vars[:page]
          vars[:params] ||= {}
          page = vars[:page].to_i
          page = 1 unless page > 0
          vars[:params][:from] = ((page - 1) * (vars[:params][:size] || 10)).ceil
        end
        # so you can pass :fields => [:field_one, :field_two]
        params = vars[:params] || {}
        params.each{|k,v| vars[:params][k] = v.join(',') if v.is_a?(Array)}
        vars
      end

      # returns Prunable if the value is nil, [], {} (called from stringified)
      def prunable?(name, vars)
        val = get_val(name, vars)
        return val if vars[:no_pruning].include?(name)
        (val.nil? || val == [] || val == {}) ? Prunable : val
      end

    private

      # allows to fetch values for tag names like 'a.3.c' fetching vars[:a][3][:c]
      def get_val(name, vars)
        return vars[name] if vars.has_key?(name) # to make tag defaults work see Tags#variables
        keys = name.to_s.split('.').map{|s| s =~ /^[0..9]+$/ ? s.to_i : s.to_sym}
        keys.inject(vars, :fetch)
      rescue NoMethodError, KeyError
        raise MissingVariableError, "required variables #{name.inspect} missing."
      end

    end
  end
end
