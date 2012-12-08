module Flex
  module ClassProxy
    module Loader

      attr_reader :templates, :partials
      include Info
      include Search

      def init
        @sources   = []
        @templates = {}
        @partials  = {}
      end

      # accepts a path to a file or YAML string
      def load_source_for(klass, source, source_vars)
        if source.nil? || source !~ /\n/m
          paths = [ "#{C11n.flex_dir}/#{source}.yml",
                    "#{C11n.flex_dir}/#{Manager.class_name_to_type(context.name)}.yml",
                    source.to_s ]
          source = paths.find {|p| File.exist?(p)}
        end
        raise ArgumentError, "expected a string (got #{source.inspect})." \
            unless source.is_a?(String)
        @sources << [klass, source, source_vars]
        do_load_source(klass, source, source_vars)
        # fixes the legacy empty stubs, which should call super instead
        @templates.keys.each do |name|
          meta_context.send(:define_method, name){|*| super }
        end
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

      def wrap(*methods, &block)
        methods = templates.keys if methods.empty?
        methods.each do |name|
          raise MissingTemplateMethodError, "#{name} is not a template method" \
                unless templates.include?(name)
          meta_context.send(:define_method, name, &block)
        end
      end

      private

      # adds a template instance and defines the template method in the host_class::TemplateMethods
      def add_template(name, template)
        templates[name] = template
        # no define_singleton_method in 1.8.7
        context::FlexTemplateMethods.send(:define_method, name) do |*vars|
          raise ArgumentError, "#{context}.#{name} expects a list of Hashes, got (\#{vars.map(&:inspect).join(', ')})" \
                unless vars.all?{|i| i.nil? || i.is_a?(Hash)}
          flex.templates[name].render(*vars)
        end
      end

      def meta_context
        class << context; self; end
      end

      def do_load_source(klass, source, source_vars)
        source = Utils.erb_process(source) unless source.match("\n") # skips non-path
        hash   = Utils.data_from_source(source)
        hash.delete('ANCHORS')
        hash.each do |name, structure|
          define_template klass, name, structure, source_vars
        end
      end

      def define_template(klass, name, structure, source_vars)
        structure = [structure] unless structure.is_a?(Array)
        if name.to_s[0] == '_' # partial
          partial = Template::Partial.new(*structure).setup(name.to_sym)
          partials[name.to_sym] = partial
        else
          template = klass.new(*structure).setup(self, name.to_sym, source_vars)
          add_template(name.to_sym, template)
        end
      end

    end
  end
end
