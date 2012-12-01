module Flex
  class Variables < Hash

    include Structure::Mergeable

    def initialize(*hashes)
      deep_merge! *hashes
    end

    def merge(hash)
      super symbolize(hash)
    end

    def merge!(hash)
      super symbolize(hash)
    end

    def store(key, val)
      super key.to_sym, symbolize(val)
    end
    alias_method :[]=, :store

  private

    def symbolize(struct)
      case struct
      when Flex::Variables
        struct
      when Hash
        h = Variables.new
        struct.each do |k,v|
          h[k.to_sym] = symbolize(v)
        end
        h
      when Array
        struct.map{|i| symbolize(i)}
      else
        struct
      end
    end

  end
end
