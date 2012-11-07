module Flex
  module ClassProxy
    module Modules
      module Search

        def define_search(name, source, source_vars=nil)
          raise ArgumentError, %(The name :#{name} starts with "_", which is reserved to partials.) \
                if name.to_s[0] == '_'
          structure = Utils.data_from_source(source)
          structure = [structure] unless structure.is_a?(Array)
          template  = Template::Search.new(*structure).setup(self, name.to_s, source_vars)
          add_template(name.to_sym, template)
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

        # implements search_type=scan (http://www.elasticsearch.org/guide/reference/api/search/search-type.html)
        def scan_search(template, vars={}, &block)
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

        # implements search_type=count (http://www.elasticsearch.org/guide/reference/api/search/search-type.html)
        def count_search(template, vars={})
          template = template.is_a?(Flex::Template) ? template : templates[template]
          template.render Variables.new(:params => {:search_type => 'count'}).add(vars)
        end

      end
    end
  end
end
