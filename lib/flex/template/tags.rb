module Flex
  class Template
    class Tags < Array

      TAG_REGEXP = /<<\s*(\w+)\s*(?:=([^>]*))*>>/

      def variables
        tag_variables = {}
        each { |t| tag_variables[t.name] = t.default if t.default || t.optional  }
        tag_variables
      end

      def stringify(structure)
        structure.inspect.gsub(/(?:"#{TAG_REGEXP}"|#{TAG_REGEXP})/) do
          match = $&
          match =~ TAG_REGEXP
          t = Tag.new($1, $2)
          push t unless find{|i| i.name == t.name}
          t.stringify(match !~ /^"/)
        end
      end

    end

    class Tag

      RESERVED = [:path, :data, :params, :page, :no_pruning, :raise]

      attr_reader :optional, :name, :default

      def initialize(name, default)
        raise SourceError, ":#{name} is a reserved symbol and cannot be used as a tag name" \
              if RESERVED.include?(name)
        @name     = name.to_sym
        @optional = !!default
        @default  = YAML.load(default) unless default.nil?
      end

      def stringify(in_string)
        in_string ? "\#{prunable?(:#{name}, vars)}" : "prunable?(:#{name}, vars)"
      end

    end

  end
end
