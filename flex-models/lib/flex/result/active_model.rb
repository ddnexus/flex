module Flex
  class Result
    module ActiveModel

      include Flex::Result::Scope

      # extend if the context include a Flex::ActiveModel
      def self.should_extend?(result)
        result.variables[:context] && result.variables[:context].include?(Flex::ActiveModel)
      end

      def get_docs
        # super is from flex-scopes
        docs = super
        return docs if variables[:raw_result]
        raw_result = self
        if docs.is_a?(Array)
          res = docs.map {|doc| build_object(doc)}
          res.extend(Struct::Paginable).setup(raw_result['hits']['total'], variables)
          class << res; self end.class_eval do
            define_method(:raw_result){ raw_result }
            define_method(:method_missing) do |meth, *args, &block|
              raw_result.respond_to?(meth) ? raw_result.send(meth, *args, &block) : super(meth, *args, &block)
            end
          end
          res
        else
          build_object docs
        end
      end

    private

      def build_object(doc)
        attrs      = (doc['_source']||{}).merge(doc['fields']||{})
        object     = variables[:context].new attrs
        raw_result = self
        object.instance_eval do
          class << self; self end.class_eval do
            define_method(:raw_result){ raw_result }
            define_method(:raw_document){ doc }
            define_method(:respond_to?) do |*args|
              doc.respond_to?(*args) || super(*args)
            end
            define_method(:method_missing) do |meth, *args, &block|
              doc.respond_to?(meth) ? doc.send(meth, *args, &block) : super(meth, *args, &block)
            end
          end
          @_id        = doc['_id']
          @_version   = doc['_version']
          @highlight  = doc['highlight']
          # load the flex proxy before freezing
          flex
          self.freeze if raw_result.variables[:params][:fields] || doc['fields']
        end
        object
      end

    end
  end
end
