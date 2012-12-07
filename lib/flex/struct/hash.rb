module Flex
  module Struct
    class Hash < ::Hash
      include Symbolize

      def initialize
        super do |hash, key|
          if key[-1] == '!'
            klass = (key[0] == '_' ? Array : Hash)
            hash[clean_key(key)] = klass.new
          end
        end
      end

      def merge(hash)
        super symbolize(hash)
      end

      def merge!(hash)
        super symbolize(hash)
      end

      def store(key, val)
        super clean_key(key), symbolize(val)
      end
      alias_method :[]=, :store

      def fetch(key, *rest, &block)
        cleaned = clean_key(key)
        super has_key?(cleaned) ? cleaned : key.to_sym, *rest, &block
      end

      def [](key)
        cleaned = clean_key(key)
        super has_key?(cleaned) ? cleaned : key.to_sym
      end

      def deep_merge(*hashes)
        dupe = deep_dup(self)
        hashes.each {|h2| dupe.replace(deep_merge_hash(dupe,h2))}
        dupe
      end

      def deep_merge!(*hashes)
        replace deep_merge(*hashes)
      end

      module Nil
        def method_missing(*)
          self
        end
      end

      def try(key)
        has_key?(key) ? self[key] : nil.extend(Nil)
      end

      def try_delete(key, *rest, &block)
        val = delete clean_key(key), *rest, &block
        val.nil? ? nil.extend(Nil) : val
      end


      private

      def clean_key(key)
        key[-1] == '!' ? key[0..-2].to_sym : key.to_sym
      end

      def deep_merge_hash(h1, h2)
        h2 ||= {}
        h1.merge(h2) do |key, oldval, newval|
          case
          when oldval.is_a?(Hash) && newval.is_a?(Hash)
            deep_merge_hash(oldval, newval)
          when oldval.is_a?(Array) && newval.is_a?(Array)
            oldval + newval
          else
            newval
          end
        end
      end

      def deep_dup(obj)
        case obj
        when ::Hash, Flex::Struct::Hash
          h = obj.dup
          h.each_pair do |k,v|
            h[k] = deep_dup(v)
          end
          h
        when ::Array, Flex::Struct::Array
          obj.map{|i| deep_dup(i)}
        else
          obj
        end
      end

    end
  end
end
