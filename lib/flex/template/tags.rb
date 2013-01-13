module Flex
  class Template
    class Tags < Array

      TAG_REGEXP = /<<\s*([\w\.]+)\s*(?:=([^>]*))*>>/

      # tag variables are the defaults defined with the tag
      # a variable could be optional, and the default could be nil
      def variables
        tag_variables = Vars.new
        each do |t|
          if t.default || t.optional
            if t.name =~ /\./ # set default for nested var
              tag_variables.store_nested(t.name, t.default)
            else
              tag_variables[t.name] = t.default
            end
          end
        end
        tag_variables
      end

      def stringify(structure)
        structure.inspect.gsub(/(?:"#{TAG_REGEXP}"|#{TAG_REGEXP})/) do
          match = $&
          match =~ TAG_REGEXP
          t = Tag.new($1, $2)
          push t unless find{|i| i.name == t.name}
          (match !~ /^"/) ? "\#{vars.get_prunable(:'#{t.name}')}" : "vars.get_prunable(:'#{t.name}')"
        end
      end

      def partial_and_tag_names
        map(&:name).partition{|n| n.to_s =~ /^_/}
      end

    end

    class Tag

      RESERVED = [:context, :path, :data, :params, :no_pruning, :raw_result, :raise]

      attr_reader :optional, :name, :default

      def initialize(name, default)
        # allows passing complex defaults like <<query={query=\ '*'>>}
        default.tr!('\\', '') if default
        raise SourceError, ":#{name} is a reserved symbol and cannot be used as a tag name" \
              if RESERVED.include?(name)
        @name     = name.to_sym
        @optional = !!default
        @default  = YAML.load(default) unless default.nil?
      end

    end

  end
end
