module Flex
  class Template

    class Prunable
      class << self
        def to_s; '' end
        alias_method :===, :==
      end
    end

    module Base

      # returns Prunable if the value is nil, [], {} (called from stringified)
      def prunable?(name, vars)
        val = get_val(name, vars)
        return val if vars[:no_pruning].include?(name)
        (val.nil? || val == '' || val == [] || val == {}) ? Prunable : val
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
