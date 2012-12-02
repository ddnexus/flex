module Flex
  module Structure
    class Hash < ::Hash
      include Symbolize

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

      def fetch(key, *rest, &block)
        super key.to_sym, *rest, &block
      end

      def [](key)
        super key.to_sym
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
        val = delete key.to_sym, *rest, &block
        val.nil? ? nil.extend(Nil) : val
      end


      private

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
        when ::Hash, Flex::Structure::Hash
          h = obj.dup
          h.each_pair do |k,v|
            h[k] = deep_dup(v)
          end
          h
        when ::Array, Flex::Structure::Array
          obj.map{|i| deep_dup(i)}
        else
          obj
        end
      end

    end
  end
end
