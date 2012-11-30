module Flex
  class Struct < OpenStruct

    def configure
      yield self
    end

  end

  # cool short name
  C11n = Struct.new :result_extenders    => [ Flex::Result::Document,
                                              Flex::Result::SourceDocument,
                                              Flex::Result::Search,
                                              Flex::Result::MultiGet,
                                              Flex::Result::SourceSearch,
                                              Flex::Result::Bulk ],
                    :logger              => Logger.new(STDERR),
                    :variables           => Variables.new( :index      => nil,
                                                           :type       => nil,
                                                           :no_pruning => [] ),
                    :flex_models         => [],
                    :config_file         => './config/flex.yml',
                    :flex_dir            => './flex',
                    :http_client         => HttpClients::Loader.get_http_client_class.new,
                    :raise_proc          => proc{|response| response.status >= 400}

  # long form alias
  Configuration = C11n

  # temprary deprecation warnings
  C11n.instance_eval do
    def base_uri(*args)
      logger.warn "The Flex::Configuration.base_uri setting is deprecated in favour of Flex::Configuration.http_client.base_uri, and will be removed in a next version (called at: #{caller.first})"
      http_client.base_uri(*args)
    end
    def http_client_options(*args)
      logger.warn "The Flex::Configuration.http_client_options setting is deprecated in favour of Flex::Configuration.http_client.options, and will be removed in a next version (called at: #{caller.first})"
      http_client.options(*args)
    end
  end

end
