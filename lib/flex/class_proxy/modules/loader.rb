module Flex
  module ClassProxy
    module Modules
      module Loader

        def self.included(base)
          base.class_eval do
            attr_reader :templates, :partials
            include Template::Info
          end
        end

        # accepts a path to a file or YAML string
        def load_source_for(klass, source, source_vars)
          if source.nil? || source != /\n/
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

        # http://www.elasticsearch.org/guide/reference/api/multi-search.html
        # request may be a hash with the templates names as keys and the variable hash as value
        # or you can also use an array of arrays.
        # The variables are an hash of variables that will be used to render the msearch template
        def multi_search(requests, variables={})
          lines    = requests.map { |name, vars| templates[name].to_msearch(vars) }.join()
          template = Template.new('GET', '/<<index>>/<<type>>/_msearch')
          template.send(:do_render, variables.merge(:data => lines)) do |http_response|
            responses   = []
            es_response = MultiJson.decode(http_response.body)
            es_response['responses'].each_with_index do |result, i|
              responses << Result.new(templates[requests[i].first], requests[i].last, http_response, result)
            end
            es_response['responses'] = responses
            def es_response.responses
              self['responses']
            end
            es_response
          end
        end

        def scroll_search(template, vars={}, &block)
          template = template.is_a?(Flex::Template) ? template : templates[template]
          vars = Variables.new( :params => { :search_type => 'scan',
                                             :scroll      => '5m',
                                             :size        => 50 } ).add(vars)
          scroll_temp = Flex::Template.new( :get,
                                            '/_search/scroll',
                                            nil,
                                            :params => { :scroll => vars[:params][:scroll] } )
          search_res  = template.render vars
          scroll_id   = search_res['_scroll_id']
          arity = host_class.method(:flex_result).arity
          while (result = scroll_temp.render(:data => scroll_id)) do
            break if result['hits']['hits'].empty?
            scroll_id = result['_scroll_id']
            res = arity == 1 ? host_class.flex_result(result) : host_class.flex_result(result, vars)
            block.call res
          end
        end

        private

        def do_load_source(klass, source, source_vars)
          source = Utils.erb_process(source) unless source.match("\n") # skips non-path
          hash   = Utils.data_from_source(source)
          hash.delete('ANCHORS')
          hash.each do |name, structure|
            if name.to_s[0] == '_' # partial
              partial = Template::Partial.new(structure, self)
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
