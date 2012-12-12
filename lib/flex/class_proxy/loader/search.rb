module Flex
  module ClassProxy
    module Loader
      module Search

        def define_search(name, source, source_vars=nil)
          args = Utils.parse_source(source)
          send :define_template, Template::Search, name, args, source_vars
        end

        # http://www.elasticsearch.org/guide/reference/api/multi-search.html
        # requests can be an array of arrays: [[:template1, variable_hash1], [template2, variable_hash2]]
        # or a hash {:template1 => variable_hash1, template2 => variable_hash2}
        # The variables are an hash of variables that will be used to render the msearch template
        # the array of result is at <result>.responses
        def multi_search(requests, *variables)
          requests = requests.map { |name, vars| [name, vars] } if requests.is_a?(Hash)
          lines    = requests.map { |name, vars| templates[name].to_msearch(vars) }.join()
          template = Template.new('GET', '/<<index>>/<<type>>/_msearch') # no setup flex so raw_result
          template.send(:do_render, *variables, :data => lines) do |http_response|
            responses   = []
            es_response = MultiJson.decode(http_response.body)
            es_response['responses'].each_with_index do |raw_result, i|
              name, vars = requests[i]
              int = templates[name].interpolate(vars, strict=true)
              result = Result.new(templates[name], int[:vars], http_response, raw_result)
              responses << result.to_flex_result
            end
            es_response['responses'] = responses
            def es_response.responses
              self['responses']
            end
            es_response
          end
        end

        # implements search_type=scan (http://www.elasticsearch.org/guide/reference/api/search/search-type.html)
        def scan_search(template, *vars, &block)
          scroll      = '5m'
          search_vars = Vars.new({:params     => { :search_type => 'scan',
                                                   :scroll      => scroll,
                                                   :size        => 50 },
                                  :raw_result => true}, *vars)
          scroll_vars = Vars.new({:params     => { :scroll => scroll },
                                  :raw_result => true}, *vars)
          search_temp = template.is_a?(Flex::Template) ? template : templates[template]
          scroll_temp = Flex::Template.new( :get,
                                            '/_search/scroll',
                                            nil,
                                            scroll_vars )
          search_res  = search_temp.render search_vars
          scroll_id   = search_res['_scroll_id']
          while (result = scroll_temp.render(:data => scroll_id)) do
            break if result['hits']['hits'].empty?
            scroll_id = result['_scroll_id']
            block.call result.to_flex_result(force=true)
          end
        end

        # implements search_type=count (http://www.elasticsearch.org/guide/reference/api/search/search-type.html)
        def count_search(template, *vars)
          template = template.is_a?(Flex::Template) ? template : templates[template]
          template.render Vars.new({:params => {:search_type => 'count'}, :raw_result => true}, *vars)
        end

      end
    end
  end
end
