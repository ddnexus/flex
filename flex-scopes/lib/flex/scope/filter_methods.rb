module Flex
  class Scope
    module FilterMethods

      include Scope::Utils

      # accepts also :any_term => nil for missing values
      def terms(value)
        terms, missing_list = {}, []
        value.each { |f, v| v.nil? ? missing_list.push({ :missing => f }) : (terms[f] = v) }
        terms, term = terms.partition{|k,v| v.is_a?(Array)}
        term_list = []
        term.each do |term, value|
          term_list.push(:term => {term => value})
        end
        deep_merge boolean_wrapper( :terms_list    => Hash[terms],
                                    :term_list     => term_list,
                                    :_missing_list => missing_list )
      end

      # accepts one or an array or a list of filter structures
      def filters(*value)
        deep_merge boolean_wrapper( :filters => array_value(value) )
      end

      def missing(*fields)
        missing_list = []
        for field in fields
          missing_list.push(:missing => field)
        end
        deep_merge :_missing_list => missing_list
      end

      # accepts a single key hash or a multiple keys hash, that will be translated in a array of single key hashes
      def term(term_or_terms_hash)
        term_list = []
        term_or_terms_hash.each do |term, value|
          term_list.push(:term => {term => value})
        end
        deep_merge boolean_wrapper(:term_list => term_list)
      end

      # accepts one hash of ranges documented at
      # http://www.elasticsearch.org/guide/reference/query-dsl/range-filter/
      def range(value)
        deep_merge boolean_wrapper(:range => value)
      end


      %w[and or].each do |m|
        class_eval <<-ruby, __FILE__, __LINE__
        def #{m}(&block)
          vars = {:_#{m} => Hash[Flex::Scope.new.instance_eval(&block).to_a]}
          vars.merge!(:_boolean_wrapper => :_#{m}) if context_scope?
          deep_merge vars
        end
        ruby
      end

    private

      def context_scope?
        has_key?(:context)
      end

      def boolean_wrapper(value)
        if context_scope?
          if has_key?(:_boolean_wrapper) && self[:_boolean_wrapper] != :_and
            current_wrapper = {self[:_boolean_wrapper] => delete(self[:_boolean_wrapper])}
            self.and{ current_wrapper }.and{ value }
          else
            self.and{value}
          end
        else
          value
        end
      end

    end
  end
end
