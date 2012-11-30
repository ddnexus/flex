module Flex
  module UtilityMethods

    # Anonymous search query: please, consider to use named templates for better performances and programming style
    # data can be a JSON string that will be passed as is, or a YAML string (that will be converted into a ruby hash)
    # or a hash. It can contain interpolation tags as usual.
    # You can pass an optional hash of interpolation arguments (or query string :params).
    # See also the Flex::Template::Search documentation
    def search(data, args={})
      Template::Search.new(data).setup(Flex.flex).render(args)
    end

    # like Flex.search, but it will use the Flex::Template::SlimSearch instead
    def slim_search(data, args={})
      Template::SlimSearch.new(data).setup(Flex.flex).render(args)
    end

    %w[HEAD GET PUT POST DELETE].each do |m|
      class_eval <<-ruby, __FILE__, __LINE__
        def #{m}(*args)
          perform '#{m}', *args
        end
      ruby
    end

    def json2yaml(json)
      YAML.dump(MultiJson.decode(json))
    end

    def yaml2json(yaml)
      MultiJson.encode(YAML.load(yaml))
    end

    # Flex.process_bulk accepts a :collection of objects, that can be hashes or Models
    # you can pass also a :action set to 'index' (default) or 'delete'
    # in order to bulk-index or bulk-delete the whole collection
    # you can use Flex.bulk if you have an already formatted bulk data-string
    def process_bulk(args)
      raise ArgumentError, "Array expected as :collection (got #{args[:collection].inspect})" \
            unless args[:collection].is_a?(Array)

      index  = args[:index]  || C11n.variables[:index]
      type   = args[:type]   || C11n.variables[:type]
      action = args[:action] || 'index'

      meta = {}
      [:version, :routing, :percolate, :parent, :timestamp, :ttl].each do |opt|
        meta["_#{opt}"] = args[opt] if args[opt]
      end
      lines = args[:collection].map do |d|
                # skips indexing for objects that return nil as the indexed_json or are not flex_indexable?
                unless action == 'delete'
                  next if d.respond_to?(:flex_indexable?) && !d.flex_indexable?
                  json = get_json(d) || next
                end
                m = {}
                m['_index']   = get_index(d) || index
                m['_type']    = get_type(d)  || type
                m['_id']      = get_id(d)    || d       # we could pass an array of ids to delete
                parent        = get_parent(d)
                m['_parent']  = parent if parent
                routing       = get_routing(d)
                m['_routing'] = routing if routing
                line = MultiJson.encode({action => meta.merge(m)})
                line << "\n#{json}" unless action == 'delete'
                line
              end.compact

      bulk(args.merge(:lines => lines.join("\n") + "\n")) if lines.size > 0
    end

    def import_collection(collection, options={})
      process_bulk( {:collection => collection,
                     :action     => 'index'}.merge(options) )

    end

    def delete_collection(collection, options={})
      process_bulk( {:collection => collection,
                     :action     => 'delete'}.merge(options) )
    end

  private

    def perform(*args)
      Template.new(*args).setup(Flex.flex).render
    end

    def get_index(d)
       d.class.flex.index if d.class.respond_to?(:flex)
    end

    def get_type(d)
      case
      when d.respond_to?(:flex)  then d.flex.type
      when d.respond_to?(:_type) then d._type
      when d.is_a?(Hash)         then d.delete(:_type) || d.delete('_type') ||
                                      d.delete(:type)  || d.delete('type')
      when d.respond_to?(:type)  then d.type
      end
    end

    def get_parent(d)
      case
      when d.respond_to?(:flex) && d.flex.parent_instance(false) then d.flex.parent_instance.id
      when d.respond_to?(:_parent) then d._parent
      when d.respond_to?(:parent)  then d.parent
      when d.is_a?(Hash)           then d.delete(:_parent) || d.delete('_parent') ||
                                        d.delete(:parent)  || d.delete('parent')
      end
    end

    def get_routing(d)
      case
      when d.respond_to?(:flex) && d.flex.routing(false) then d.flex.routing
      when d.respond_to?(:_routing) then d._routing
      when d.respond_to?(:routing)  then d.routing
      when d.is_a?(Hash)            then d.delete(:_routing) || d.delete('_routing') ||
                                         d.delete(:routing)  || d.delete('routing')
      end
    end

    def get_id(d)
      case
      when d.is_a?(Hash)      then  d.delete(:_id) || d.delete('_id') ||
                                    d.delete(:id)  || d.delete('id')
      when d.respond_to?(:id) then  d.id
      end
    end

    def get_json(d)
      case
      when d.respond_to?(:flex_source)
        json = d.flex_source
        json.is_a?(String) ? json : MultiJson.encode(json)
      when d.respond_to?(:to_json)
        d.to_json
      else MultiJson.encode(d)
      end
    end

  end
end
