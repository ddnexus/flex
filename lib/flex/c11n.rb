module Flex

  # cool short name
  C11n = OpenStruct.new :result_extenders => [ Flex::Result::Document,
                                               Flex::Result::SourceDocument,
                                               Flex::Result::Search,
                                               Flex::Result::MultiGet,
                                               Flex::Result::SourceSearch,
                                               Flex::Result::Bulk ],
                        :logger           => Logger.new(STDERR),
                        :variables        => Variables.new( :index      => nil,
                                                            :type       => nil,
                                                            :no_pruning => [] ),
                        :flex_models      => [],
                        :config_file      => './config/flex.yml',
                        :flex_dir         => './flex',
                        :http_client      => HttpClients::Loader.get_http_client_class.new,
                        :raise_proc       => proc{|response| response.status >= 400}

  # long form alias
  Configuration = C11n

  C11n.instance_eval do
    def configure
      yield self
    end

    # temprary deprecation warnings
    def base_uri
      Utils.deprecate 'Flex::Configuration.base_uri', 'Flex::Configuration.http_client.base_uri'
      http_client.base_uri
    end
    def base_uri=(val)
      Utils.deprecate 'Flex::Configuration.base_uri', 'Flex::Configuration.http_client.base_uri'
      http_client.base_uri = val
    end
    def http_client_options
      Utils.deprecate 'Flex::Configuration.http_client_options', 'Flex::Configuration.http_client.options'
      http_client.options
    end
    def http_client_options=(val)
      Utils.deprecate 'Flex::Configuration.http_client_options', 'Flex::Configuration.http_client.options'
      http_client.options = val
    end
  end

end
