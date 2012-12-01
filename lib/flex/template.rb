module Flex

  # Generic Flex::Template object.
  # This class represents a generic Flex::Template object.
  # It is used as the base class by all the more specific Flex::Template::* classes.
  # You  usually don't need to instantiate this class manually, since it is usually used internally.
  # For more details about templates, see the documentation.
  class Template

    include Base
    include Logger

    def self.variables
      Variables.new
    end

    attr_reader :method, :path, :data, :tags, :partials, :name

    def initialize(method, path, data=nil, vars=nil)
      @method = method.to_s.upcase
      raise ArgumentError, "#@method method not supported" \
            unless %w[HEAD GET PUT POST DELETE].include?(@method)
      @path          = path =~ /^\// ? path : "/#{path}"
      @data          = Utils.data_from_source(data)
      @instance_vars = vars
    end

    def setup(host_flex, name=nil, source_vars=nil)
      @host_flex   = host_flex
      @name        = name
      @source_vars = source_vars
      self
    end

    def render(vars={})
      do_render(vars) do |response, int|
        Result.new(self, int[:vars], response).to_flex_result
      end
    end

    def to_a(vars={})
      int = interpolate(vars)
      a = [method, int[:path], int[:data], @instance_vars]
      2.times { a.pop if a.last.nil? }
      a
    end

    def to_source
      {@name.to_s => to_a}.to_yaml
    end


  private

    def do_render(vars={})
      int          = interpolate(vars, strict=true)
      path         = build_path(int, vars)
      encoded_data = build_data(int, vars)
      response     = C11n.http_client.request(method, path, encoded_data)
      # used in Flex.exist?
      return response.status == 200 if method == 'HEAD'
      if C11n.raise_proc.call(response)
        int[:vars][:raise].is_a?(FalseClass) ? return : raise(HttpError.new(response, caller_line))
      end
      result = yield(response, int)
    ensure
      log_render int, path, encoded_data, result
    end

    def build_path(int, vars)
      params = int[:vars][:params]
      path   = vars[:path] || int[:path]
      if params
        path << ((path =~ /\?/) ? '&' : '?')
        path << params.map { |p| p.join('=') }.join('&')
      end
      path
    end

    def build_data(int, vars)
      data = vars[:data] && Utils.data_from_source(vars[:data]) || int[:data]
      (data.nil? || data.is_a?(String)) ? data : MultiJson.encode(data)
    end

    def interpolate(*args)
      tags        = Tags.new
      stringified = tags.stringify(:path => @path, :data => @data)
      @partials, @tags = tags.partial_and_tag_names
      @base_variables  = C11n.variables.deep_merge(self.class.variables)
      @temp_variables  = Variables.new.deep_merge(@source_vars, @instance_vars, tags.variables)
      instance_eval <<-ruby, __FILE__, __LINE__
        def interpolate(vars={}, strict=false)
          return {:path => path, :data => data, :vars => vars} if vars.empty? && !strict
          sym_vars = {}
          vars.each{|k,v| sym_vars[k.to_sym] = v} # so you can pass the rails params hash
          context_variables = vars[:context] ? vars[:context].flex.variables : (@host_flex && @host_flex.variables)
          merged = @base_variables.deep_merge(context_variables, @temp_variables, sym_vars)
          vars   = process_vars(merged)
          obj    = #{stringified}
          obj    = prune(obj)
          obj[:path].tr_s!('/', '/')     # removes empty path segments
          obj[:vars] = vars
          obj
        end
      ruby
      interpolate(*args)
    end

    # prunes the branch when the leaf is Prunable
    # and compact.flatten the Array values
    def prune(obj)
      case obj
      when Prunable, [], {}
        obj
      when Array
        ar = []
        obj.each do |i|
          pruned = prune(i)
          next if pruned == Prunable
          ar << pruned
        end
        a = ar.compact.flatten
        a.empty? ? Prunable : a
      when Hash
        h = {}
        obj.each do |k, v|
          pruned = prune(v)
          next if pruned == Prunable
          h[k] = pruned
        end
        h.empty? ? Prunable : h
      else
        obj
      end
    end

  end
end
