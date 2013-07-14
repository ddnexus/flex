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

    def reload!
      flex.variables.deep_merge! Conf.variables
      Templates.contexts.each {|c| c.flex.reload!}
      true
    end

    def doc(*args)
      flex.doc(*args)
    end

    def scan_search(*args, &block)
      flex.scan_search(*args, &block)
    end

    def scan_all(*args, &block)
      flex.scan_search(:match_all, *args) do |raw_result|
        batch = raw_result['hits']['hits']
        block.call(batch)
      end
    end

    def dump_all(*args, &block)
      scan_all({:params => {:fields => '*,_source'}}, *args, &block)
    end

    # You should use Flex.post_bulk_string if you have an already formatted bulk data-string
    def post_bulk_collection(collection, options={})
      raise ArgumentError, "Array expected as :collection, got #{collection.inspect}" \
            unless collection.is_a?(Array)
      bulk_string = ''
      collection.each do |d|
        bulk_string << build_bulk_string(d, options)
      end
      post_bulk_string(:bulk_string => bulk_string) unless lines.empty?
    end

    def build_bulk_string(d, options={})
      case
      when d.is_a?(Hash)
        bulk_string_from_hash(d, options)
      when d.is_a?(Flex::ModelIndexer) || d.is_a?(Flex::ActiveModel)
        bulk_string_from_flex(d, options)
      else
        raise NotImplementedError, "Unable to convert the document #{d.inspect} to a bulk entry."
      end
    end

  private

    def perform(*args)
      Template.new(*args).setup(Flex.flex).render
    end

    def bulk_string_from_hash(d, options)
      meta = Utils.slice_hash(d, '_index', '_type', '_id')
      if d.has_key?('fields')
        d['fields'].each do |k, v|
          meta[k] = v if k[0] == '_'
        end
      end
      source = d['_source'] unless action == 'delete'
      to_bulk_string(meta, source, options)
    end

    def bulk_string_from_flex(d, options)
      flex = d.flex
      meta = { '_index' => flex.index,
               '_type'  => flex.type,
               '_id'    => flex.id }
      meta['_parent']  = flex.parent if flex.parent
      meta['_routing'] = flex.routing if flex.routing
      source = d.flex_source if d.flex_indexable? && ! action == 'delete'
      to_bulk_string(meta, source, options)
    end

    def to_bulk_string(meta, source, options)
      action = options[:action] || 'index'
      return '' if source.nil? || source.empty? && ! action == 'delete'
      entry  = MultiJson.encode(action => meta) + "\n"
      unless action == 'delete'
        source_line = source.is_a?(String) ? source : MultiJson.encode(source)
        return '' if source.nil? || source.empty?
        entry << source_line + "\n"
      end
      entry
    end

  end
end
