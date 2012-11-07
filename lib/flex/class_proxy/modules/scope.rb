module Flex
  module ClassProxy
    module Modules
      module Scope

        def scope(name, source, source_vars=nil)
          raise ArgumentError, %(The scope name :#{name} starts with "_", which is reserved to partial templates.) \
                if name.to_s[0] == '_'
          structure = Utils.data_from_source(source)
          structure = [structure] unless structure.is_a?(Array)
          template  = Template::Search.new(*structure).setup(self, name.to_s, source_vars)
          add_template(name.to_sym, template)
        end

      end
    end
  end
end
