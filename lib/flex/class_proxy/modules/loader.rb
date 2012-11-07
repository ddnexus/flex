module Flex
  module ClassProxy
    module Modules
      module Loader

        def self.included(base)
          base.class_eval do
            attr_reader :templates, :partials
            include Template::Info
            include Search
          end
        end

        # accepts a path to a file or YAML string
        def load_source_for(klass, source, source_vars)
          if source.nil? || source !~ /\n/m
            paths = [ "#{Configuration.flex_dir}/#{source}.yml",
                      "#{Configuration.flex_dir}/#{Manager.class_name_to_type(host_class.name)}.yml",
                      source.to_s ]
            source = paths.find {|p| File.exist?(p)}
          end
          raise ArgumentError, "expected a string (got #{source.inspect})." \
              unless source.is_a?(String)
          @sources << [klass, source, source_vars]
          do_load_source(klass, source, source_vars)
        end

        # loads a Generic Template source
        def load_source(source=nil, source_vars=nil)
          load_source_for(Template, source, source_vars)
        end

        # loads a Search Template source
        def load_search_source(source=nil, source_vars=nil)
          load_source_for(Template::Search, source, source_vars)
        end

        # loads a SlimSearch Template source
        def load_slim_search_source(source=nil, source_vars=nil)
          load_source_for(Template::SlimSearch, source, source_vars)
        end

        # reloads the sources (useful in the console and used internally)
        def reload!
          @sources.each {|k,s,v| do_load_source(k,s,v)}
        end

        # adds a template instance and defines the template method in the host class
        def add_template(name, template)
          templates[name] = template
          # no define_singleton_method in 1.8.7
          host_class.instance_eval <<-ruby, __FILE__, __LINE__ + 1
            def #{name}(vars={})
              raise ArgumentError, "#{host_class}.#{name} expects a Hash (got \#{vars.inspect})" unless vars.is_a?(Hash)
              result = flex.templates[:#{name}].render(vars)
              method(:flex_result).arity == 1 ? flex_result(result) : flex_result(result, vars)
            end
            ruby
        end

        private

        def do_load_source(klass, source, source_vars)
          source = Utils.erb_process(source) unless source.match("\n") # skips non-path
          hash   = Utils.data_from_source(source)
          hash.delete('ANCHORS')
          hash.each do |name, structure|
            if name.to_s[0] == '_' # partial
              partial = Template::Partial.new(structure)
              partials[name.to_sym] = partial
            else
              template = klass.new(*structure).setup(self, name, source_vars)
              add_template(name.to_sym, template)
            end
          end
        end

      end
    end
  end
end
