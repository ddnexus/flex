module Flex
  module UtilityMethods

    def search(data, vars={})
      Template::Search.new(data).setup(Flex.flex).render(vars)
    end

    # like Flex.search, but it will use the Flex::Template::SlimSearch instead
    def slim_search(data, vars={})
      Template::SlimSearch.new(data).setup(Flex.flex).render(vars)
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

    def scan_all(*vars, &block)
      flex.scan_search(:match_all, *vars) do |raw_result|
        batch = raw_result['hits']['hits']
        block.call(batch)
      end
    end

    def dump_all(*vars, &block)
      scan_all({:params => {:fields => '*,_source'}}, *vars) do |batch|
        batch.map!{|d| d.delete('_score'); doc}
        block.call(batch)
      end
    end

    def dump_one(*vars)
      document = search_by_id({:params => {:fields => '*,_source'}, :refresh => true}, *vars)
      document.delete('_score')
      document
    end

    # You should use Flex.post_bulk_string if you have an already formatted bulk data-string
    def post_bulk_collection(collection, options={})
      raise ArgumentError, "Array expected as :collection, got #{collection.inspect}" \
            unless collection.is_a?(Array)
      bulk_string = ''
      collection.each do |d|
        bulk_string << build_bulk_string(d, options)
      end
      post_bulk_string(:bulk_string => bulk_string) unless bulk_string.empty?
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
      source = d['_source'] unless options[:action] == 'delete'
      to_bulk_string(meta, source, options)
    end

    def bulk_string_from_flex(d, options)
      flex = d.flex
      meta = { '_index' => flex.index,
               '_type'  => flex.type,
               '_id'    => flex.id }
      meta['_parent']  = flex.parent if flex.parent
      meta['_routing'] = flex.routing if flex.routing
      source = d.flex_source if d.flex_indexable? && ! options[:action] == 'delete'
      to_bulk_string(meta, source, options)
    end

    def to_bulk_string(meta, source, options)
      action = options[:action] || 'index'
      return '' if source.nil? || source.empty? && ! action == 'delete'
      if defined?(LiveReindex) && options[:reindexing]
        meta['_index'] = LiveReindex.prefix_index(meta['_index'])
      end
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
