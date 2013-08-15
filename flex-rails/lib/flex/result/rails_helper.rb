module Flex
  class Result
    module RailsHelper

      module Highlighter

        RE = /highlighted_(\w+)/

        def respond_to?(meth, private=false)
          meth.to_s =~ RE
          !!$1 || super
        end

        def method_missing(meth, *args, &block)
          meth.to_s =~ RE
          attribute = $1
          if attribute
            opts = {:fragment_separator => ' ... '}.merge(args.first||{})
            if self['highlight']
              key, high = self['highlight'].find { |k,v| k.gsub('.','_') == attribute }
              high = Array.wrap(high) if high
            end
            if high.blank?
              respond_to?(attribute.to_sym) ? send(attribute.to_sym) : ''
            else
              high.join(opts[:fragment_separator]).html_safe
            end
          else
            super
          end
        end

      end


      # extend if result is a Search or MultiGet
      def self.should_extend?(result)
        result.is_a?(Search) || result.is_a?(MultiGet)
      end

      # extend the collection on extend
      def self.extended(result)
        result.collection.each { |h| h.extend(Highlighter) }
      end

    end
  end
end
