module Flex
  class Tasks

    attr_reader :options

    def initialize(overrides={})
      options = Flex::Utils.env2options *default_options.keys
      options[:index] = options[:index].split(',') if options[:index]
      @options = default_options.merge(options).merge(overrides)
    end

    def default_options
      @default_options ||= { :force          => false,
                             :index          => Conf.variables[:index],
                             :config_file    => Conf.config_file }
    end

    def create_indices
      indices.each do |index|
        delete_index(index) if options[:force]
        raise ExistingIndexError, "#{index.inspect} already exists. Please use FORCE=1 if you want to delete it first." \
              if exist?(index)
        create(index)
      end
    end

    def delete_indices
      indices.each { |index| delete_index(index) }
    end

    def config_hash
      @config_hash ||= ( hash = YAML.load(Utils.erb_process(config_path))
                         Utils.delete_allcaps_keys(hash) )
    end

  private

    def indices
      i = options[:index] || config_hash.keys
      i.is_a?(Array) ? i : [i]
    end

    def exist?(index)
      Flex.exist?(:index => index)
    end

    def config_path
      @config_path ||= options[:config_file] || Conf.config_file
    end

    def delete_index(index)
      Flex.delete_index(:index => index) if exist?(index)
    end

    def create(index)
      raise MissingIndexEntryError, "no #{index.inspect} entry defined in #{config_path}" \
            unless config_hash.has_key?(index)
      Flex.POST "/#{index}", config_hash[index]
    end

  end

end
