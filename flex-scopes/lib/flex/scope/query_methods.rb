module Flex
  class Scope

    module Query

      include Templates
      flex.load_source File.expand_path('../queries.yml', __FILE__)

    end

    module QueryMethods

      #    MyModel.find(ids, *vars)
      #    - ids can be a single id or an array of ids
      #
      #    MyModel.find '1Momf4s0QViv-yc7wjaDCA'
      #      #=> #<MyModel ... color: "red", size: "small">
      #
      #    MyModel.find ['1Momf4s0QViv-yc7wjaDCA', 'BFdIETdNQv-CuCxG_y2r8g']
      #      #=> [#<MyModel ... color: "red", size: "small">, #<MyModel ... color: "bue", size: "small">]
      #
      def find(ids, *vars)
        raise ArgumentError, "Empty argument passed (got #{ids.inspect})" \
              if ids.nil? || ids.respond_to?(:empty?) && ids.empty?
        wrapped = ids.is_a?(::Array) ? ids : [ids]
        result  = Query.ids self, *vars, :ids => wrapped
        docs    = result.get_docs
        ids.is_a?(::Array) ? docs : docs.first
      end

      # it limits the size of the query to the first document and returns it as a single document object
      def first(*vars)
        result = Query.get params(:size => 1), *vars
        docs   = result.get_docs
        docs.is_a?(Array) ? docs.first : docs
      end

      # it limits the size of the query to the last document and returns it as a single document object
      def last(*vars)
        result = Query.get params(:from => count-1, :size => 1), *vars
        docs   = result.get_docs
        docs.is_a?(Array) ? docs.first : docs
      end

      # will retrieve all documents, the results will be limited by the default :size param
      # use #scan_all if you want to really retrieve all documents (in batches)
      def all(*vars)
        result = Query.get self, *vars
        result.get_docs
      end

      def each(*vars, &block)
        all(*vars).each &block
      end

      # scan_search: the block will be yielded many times with an array of batched results.
      # You can pass :scroll and :size as params in order to control the action.
      # See http://www.elasticsearch.org/guide/reference/api/search/scroll.html
      def scan_all(*vars, &block)
        Query.flex.scan_search(:get, self, *vars) do |result|
          block.call result.get_docs
        end
      end
      alias_method :each_batch, :scan_all
      alias_method :find_in_batches, :scan_all

      def delete(*vars)
        Query.delete self, *vars
      end

      # performs a count search on the scope
      # you can pass a template name as the first arg and
      # it will be used to compute the count. For example:
      # SearchClass.scoped.count(:search_template, vars)
      #
      def count(*vars)
        result = if vars.first.is_a?(Symbol)
                   template = vars.shift
                   # preserves an eventual wrapper by calling the template method
                   self[:context].send(template, params(:search_type => 'count'), *vars)
                 else
                   Query.flex.count_search(:get, self, *vars)
                 end
        result['hits']['total']
      end

    end
  end
end
