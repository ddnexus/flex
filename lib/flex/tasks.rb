module Flex
  module Tasks
    extend self

    def create_indices
      indices.each do |index|
        delete_index(index) if ENV['FORCE']
        raise ExistingIndexError, "#{index.inspect} already exists. Please use FORCE=1 if you want to delete it first." \
              if exist?(index)
        create(index)
      end
    end

    def delete_indices
      indices.each { |index| delete_index(index) }
    end

    def import_models
      require 'progressbar'

      Configuration.http_client_options[:timeout]   = ENV['TIMEOUT'].to_i if ENV['TIMEOUT']
      Configuration.http_client_options[:timeout] ||= 20
      Configuration.debug = !!ENV['FLEX_DEBUG']
      batch_size = ENV['BATCH_SIZE'] && ENV['BATCH_SIZE'].to_i || 1000
      options = {}
      if ENV['IMPORT_OPTIONS']
        ENV['IMPORT_OPTIONS'].split('&').each do |pair|
          k, v  = pair.split('=')
          options[k.to_sym] = v
        end
      end
      deleted    = []

      models.each do |klass|
        index = klass.flex.index

        if ENV['FORCE']
          unless deleted.include?(index)
            delete_index(index)
            deleted << index
            puts "#{index} index deleted"
          end
        end

        unless exist?(index)
          create(index)
          puts "#{index} index created"
        end

        if defined?(Mongoid::Document) && klass.ancestors.include?(Mongoid::Document)
          def klass.find_in_batches(options={})
            0.step(count, options[:batch_size]) do |offset|
              yield limit(options[:batch_size]).skip(offset).to_a
            end
          end
        end

        unless klass.respond_to?(:find_in_batches)
          STDERR.puts "[ERROR] Class #{klass} does not respond to :find_in_batches. Skipped."
          next
        end

        total_count      = klass.count
        successful_count = 0
        failed_count     = 0

        pbar = ProgressBar.new('processing...', total_count)
        pbar.clear
        pbar.bar_mark = '|'
        puts '_' * pbar.send(:get_term_width)
        puts "Class #{klass}: indexing #{total_count} documents in batches of #{batch_size}:\n"
        pbar.send(:show)

        klass.find_in_batches(:batch_size => batch_size) do |array|
          opts   = {:index => index}.merge(options)
          result = Flex.import_collection(array, opts) || next
          Configuration.logger.error "[FLEX] Failed imports:\n#{result.failed.to_yaml}" unless result.failed.size == 0
          failed_count     += result.failed.size
          successful_count += result.successful.size
          pbar.inc(array.size)
        end

        pbar.finish
        puts "Processed #{total_count}. Successful #{successful_count}. Skipped #{total_count - successful_count - failed_count}. Failed #{failed_count}."
        puts "See the log for the details about the failed import." unless failed_count == 0

      end
    end

  private

    def indices
      indices = ENV['INDICES'] || struct.keys
      indices = eval(indices) if indices.is_a?(String)
      indices = [indices] unless indices.is_a?(Array)
      indices
    end

    def exist?(index)
      Flex.exist?(:index => index)
    end

    def struct
      @struct ||= begin
                    @indices_yaml = ENV['CONFIG_FILE'] || Flex::Configuration.config_file
                    raise Errno::ENOENT, "no such file or directory #{@indices_yaml.inspect}. " +
                                         'Please, use CONFIG_FILE=/path/to/index.yml ' +
                                         'or set the Flex::Configuration.config_file properly' \
                          unless File.exist?(@indices_yaml)
                    Manager.indices(@indices_yaml)
                  end
    end


    def models
      @models ||= begin
        mods = ENV['MODELS'] || Flex::Configuration.flex_models
        raise AgrumentError, 'no class defined. Please use MODELS=[ClassA,ClassB]' +
                             'or set the Flex::Configuration.flex_models properly' \
              if mods.nil? || mods.empty?
        mods = eval(mods) if mods.is_a?(String)
        mods = [mods] unless mods.is_a?(Array)
        mods.map{|c| c.is_a?(String) ? eval("::#{c}") : c}
      end
    end

    def delete_index(index)
      Flex.delete_index(:index => index) if exist?(index)
    end

    def create(index)
      raise MissingIndexEntryError, "no #{index.inspect} entry defined in #@indices_yaml" \
            unless struct.has_key?(index)
      Flex.POST "/#{index}", struct[index]
    end

  end
end
