module Flex
  module Utils
    extend self

    def data_from_source(source)
      return unless source
      data = case source
             when Hash              then stringified_hash(source)
             when /^\s*\{.+\}\s*$/m then source
             when String            then YAML.load(source)
             else raise ArgumentError, "expected a String or Hash instance (got #{source.inspect})"
             end
      raise ArgumentError, "the source does not decode to an Array, Hash or String (got #{data.inspect})" \
            unless data.is_a?(Hash) || data.is_a?(Array) || data.is_a?(String)
      data
    end

    def erb_process(source)
      varname = "_flex_#{source.hash.to_s.tr('-', '_')}"
      ERB.new(File.read(source), nil, nil, varname).result
    end

    def group_array_by(ary)
      h = {}
      ary.each do |i|
        k = yield i
        if h.has_key?(k)
          h[k] << i
        else
          h[k] = [i]
        end
      end
      h
    end

    def stringified_hash(hash)
      h = {}
      hash.each do |k,v|
        h[k.to_s] = v.is_a?(Hash) ? stringified_hash(v) : v
      end
      h
    end

    def load_tasks
      load File.expand_path('../../tasks/index.rake', __FILE__)
    end

    module Delegation

      extend self

      def delegate(mod, *methods)
        to = methods.pop[:to]

        file, line = caller.first.split(':', 2)
        line = line.to_i

        methods.each do |method|
          mod.module_eval(<<-method, file, line - 2)
            def #{method}(*args, &block)                        # def method_name(*args, &block)
              if #{to} || #{to}.respond_to?(:#{method})         #   if client || client.respond_to?(:name)
                #{to}.__send__(:#{method}, *args, &block)       #     client.__send__(:name, *args, &block)
              end                                               #   end
            end                                                 # end
          method
        end

      end

    end

  end
end
