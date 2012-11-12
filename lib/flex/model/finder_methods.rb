module Flex
  module Model
    module FinderMethods

      METHODS = [:find, :scoped, :scope]

      def self.extended(base)
        base.class_eval do
          @scopes = []
          def self.scopes; @scopes end
        end
      end

      #    MyModel.find(ids, vars={})
      #    - ids can be a single id or an array of ids

      #    MyModel.find '1Momf4s0QViv-yc7wjaDCA'
      #      #=> #<MyModel ... color: "red", size: "small">

      #    MyModel.find ['1Momf4s0QViv-yc7wjaDCA', 'BFdIETdNQv-CuCxG_y2r8g']
      #      #=> [#<MyModel ... color: "red", size: "small">, #<MyModel ... color: "bue", size: "small">]

      def find(ids, vars={})
        result = if ids.is_a?(Array)
                   Flex.multi_get flex.variables.deep_merge({:ids => ids}, vars)
                 else
                   Flex.get flex.variables.deep_merge({:id => ids}, vars)
                 end
        flex_result(result, vars)
      end


      #    scoped methods. They returns a Scoped object similar to AR.
      #    You can chain scopes, then you can call :count, :first, :all and :scan_all to get your result
      #    See Flex::Persistence::Scoped
      #
      #    scoped = MyModel.terms(:field_one => 'something', :field_two => nil)
      #                    .sort(:field_three => :desc)
      #                    .filters(:range => {:created_at => {:from => 2.days.ago, :to => Time.now})
      #                    .fields('field_one,field_two,field_three') # or [:field_one, :field_two, ...]
      #                    .params(:any => 'param')
      #
      #    # add another filter or other terms at any time
      #    scoped2 = scoped.terms(...).filters(...)
      #
      #    scoped2.count
      #    scoped2.first
      #    scoped2.all
      #    scoped2.scan_all {|batch| do_something_with_results batch}
      #
      Utils.define_delegation :to  => :scoped,
                              :in  => self,
                              :by  => :module_eval,
                              :for => Scoped::METHODS


      # You can start with a non restricted Flex::Persistence::Scoped object
      def scoped
        Scoped.new(self)
      end


      #    define scopes as class methods
      #
      #  class MyModel
      #    include Flex::StoredModel
      #    ...
      #    scope :red, terms(:color => 'red').sort(:supplier => :asc)
      #    scope :size do |size|
      #      terms(:size => size)
      #    end
      #
      #    MyModel.size('large').first
      #    MyModel.red.all
      #    MyModel.size('small').red.all
      #
      def scope(name, scoped=nil, &block)
        host_class = eval(self.name.gsub(/::FinderProxy/, ''))
        raise ArgumentError, "Dangerous scope name: a :#{name} method is already defined. Please, use another one." \
              if host_class.respond_to?(name) || respond_to?(name)
        proc = case
               when block_given?
                 block
               when scoped.is_a?(Scoped)
                 lambda {scoped}
               when scoped.is_a?(Proc)
                 scoped
               else
                 raise ArgumentError, "Scoped object or Proc expected (got #{scoped.inspect})"
               end
        metaclass = class << self; self end
        metaclass.send(:define_method, name) do |*args|
          scoped = proc.call(*args)
          raise Scoped::Error, "The scope :#{name} does not return a Flex::Scoped object" \
                unless scoped.is_a?(Scoped)
          scoped
        end
        Utils.define_delegation :to  => self,
                                :in  => host_class,
                                :by  => :instance_eval,
                                :for => [name]
        @scopes << name
      end

    end
  end
end
