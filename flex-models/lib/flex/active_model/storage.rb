module Flex
  module ActiveModel

    class DocumentInvalidError < StandardError; end

    module Storage

      module ClassMethods

        def create(args={})
          document = new(args)
          return false unless document.valid?
          document.save
        end

      end


      module InstanceMethods

        def reload
          document        = flex.get
          self.attributes = document['_source']
          @_id            = document['_id']
          @_version       = document['_version']
        end

        def save(options={})
          perform_validations(options) ? do_save : false
        end

        def save!(options={})
          perform_validations(options) ? do_save : raise(DocumentInvalidError, errors.full_messages.join(", "))
        end

        # Optimistic Lock Update
        #
        #    doc.safe_update do |d|
        #      d.amount += 100
        #    end
        #
        # if you are trying to update a stale object, the block is yielded again with a fresh reloaded document and the
        # document is saved only when it is not stale anymore (i.e. the _version has not changed since it has been loaded)
        # read: http://www.elasticsearch.org/blog/2011/02/08/versioning.html
        #
        def safe_update(options={}, &block)
          perform_validations(options) ? lock_update(&block) : false
        end

        def safe_update!(options={}, &block)
          perform_validations(options) ? lock_update(&block) : raise(DocumentInvalidError, errors.full_messages.join(", "))
        end

        def valid?(context = nil)
          context ||= (new_record? ? :create : :update)
          output = super(context)
          errors.empty? && output
        end

        def destroy
          @destroyed = true
          flex.sync
          self.freeze
        end

        def delete
          @skip_destroy_callbacks = true
          destroy
        end

        def merge_attributes(attributes)
          attributes.each {|name, value| send "#{name}=", value }
        end

        def update_attributes(attributes)
          merge_attributes(attributes)
          save
        end

        def destroyed?
          !!@destroyed
        end

        def persisted?
          !(new_record? || destroyed?)
        end

        def new_record?
          !@_id || !@_version
        end

      private

        def do_save
          flex.sync
          self
        end

        def lock_update
          begin
            yield self
            flex.sync
          rescue Flex::HttpError => e
            if e.status == 409
              reload
              retry
            else
              raise
            end
          end
          self
        end

      protected

        def perform_validations(options={})
          perform_validation = options[:validate] != false
          perform_validation ? valid?(options[:context]) : true
        end

      end

    end


  end
end
