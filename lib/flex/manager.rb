module Flex
  module Manager

    extend self

    attr_accessor :parent_types
    @parent_types = []

    def init_models
      C11n.flex_models.each {|m| eval"::#{m}" if m.is_a?(String) }
    end

    # arrays of all the types
    def types
      @types ||= C11n.flex_models.map {|m| (m.is_a?(String) ? eval("::#{m}") : m).flex.type }.flatten
    end

    # sets the default parent/child mappings and merges with the config_file
    # returns the indices structure used for creating the indices
    def indices(file=C11n.config_file)
      @indices ||= ( default = {}.extend Struct::Mergeable
                     C11n.flex_models.each do |m|
                       m = eval"::#{m}" if m.is_a?(String)
                       if m.flex.is_child?
                         index = m.flex.index
                         m.flex.parent_child_map.each do |parent, child|
                           default.deep_merge! index => {'mappings' => {child => {'_parent' => {'type' => parent}}}}
                         end
                       end
                       # support for flex-persistence attribute :properties, :analyzed and :not_analyzed
                       if defined?(Flex::StoredModel) && m.include?(Flex::StoredModel)
                         default.deep_merge! m.flex.get_index_mapping
                       end
                     end
                     hash = YAML.load(Utils.erb_process(file))
                     hash.delete('ANCHORS')
                     default.deep_merge(hash) )
    end

    # maps all the index/types to the ruby class
    def type_class_map
      @type_class_map ||= ( map = {}
                            C11n.flex_models.each do |m|
                              m = eval("::#{m}") if m.is_a?(String)
                              types = m.flex.type.is_a?(Array) ? m.flex.type : [m.flex.type]
                              types.each do |t|
                                map["#{m.flex.index}/#{t}"] = m
                              end
                            end
                            map )
    end

    def class_name_to_type(class_name)
      type = class_name.tr(':', '_')
      type.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      type.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      type.downcase!
      type
    end

    def type_to_class_name(type)
      type.gsub(/__(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end

  end
end
