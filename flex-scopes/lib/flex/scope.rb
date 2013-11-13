module Flex
  # never instantiate this class directly: it is automatically done by the scoped method
  class Scope < Vars

    class Error < StandardError; end

    include FilterMethods
    include VarsMethods
    include QueryMethods

    SCOPED_METHODS = FilterMethods.instance_methods + VarsMethods.instance_methods + QueryMethods.instance_methods

    def inspect
      "#<#{self.class.name} #{self}>"
    end

    def respond_to?(meth, private=false)
      super || is_template?(meth) || is_context_scope?(meth) || is_self_scope?(meth)
    end

    def method_missing(meth, *args, &block)
      super unless respond_to?(meth)
      case
      when is_context_scope?(meth)
        deep_merge self[:context].send(meth, *args, &block)
      when is_self_context_scope?(meth)
        deep_merge self[:self_context].send(meth, *args, &block)
      when is_template?(meth)
        self[:context].send(meth, deep_merge(*args), &block)
      end
    end

  private

    def is_template?(name)
      self[:context].respond_to?(:template_methods) && self[:context].template_methods.include?(name.to_sym)
    end

    def is_context_scope?(name)
      self[:context].respond_to?(:scope_methods) && self[:context].scope_methods.include?(name.to_sym)
    end

    # only used for AR scopes, when you namespace the scope module
    def is_self_scope?(name)
      self[:self_context].respond_to?(:scope_methods) && self[:self_context].scope_methods.include?(name.to_sym)
    end

  end
end
