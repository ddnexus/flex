require 'base64'
module Flex
  module ActiveModel
    module Attachment

      # defines accessors for <attachment_field_name>
      # if you omit the arguments it uses :attachment as the <attachment_field_name>
      # you can also pass other properties that will be merged with the default property for attachment
      # this will automatically add a :<attachment_field_name>_scope scope which will add
      # all the meta fields (title, author, ...) to the returned fields, exluding the <attachment_field_name> field itself
      # and including all the other attributes declared before it. For that reason you may want to declare it as
      # the latest attribute.

      def attribute_attachment(*args)
        name  = args.first.is_a?(Symbol) ? args.shift : :attachment
        props = {:properties => { 'type'   => 'attachment',
                                  'fields' => { name.to_s      => { 'store' => 'yes', 'term_vector' => 'with_positions_offsets' },
                                                'title'        => { 'store' => 'yes' },
                                                'author'       => { 'store' => 'yes' },
                                                'name'         => { 'store' => 'yes' },
                                                'content_type' => { 'store' => 'yes' },
                                                'date'         => { 'store' => 'yes' },
                                                'keywords'     => { 'store' => 'yes' }
                                              }
                                }
                }
        props.extend(Struct::Mergeable).deep_merge! args.first if args.first.is_a?(Hash)

        scope :"#{name}_scope", fields("#{name}.title",
                                       "#{name}.author",
                                       "#{name}.name",
                                       "#{name}.content_type",
                                       "#{name}.date",
                                       "#{name}.keywords",
                                       *attributes.keys)
        attribute name, props

      end

    end
  end
end
