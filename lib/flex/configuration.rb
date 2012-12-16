module Flex

  Configuration = OpenStruct.new :result_extenders => [ Result::Document,
                                                        Result::SourceDocument,
                                                        Result::Search,
                                                        Result::MultiGet,
                                                        Result::SourceSearch,
                                                        Result::Bulk ],
                                 :logger           => Logger.new(STDERR),
                                 :variables        => Vars.new( :index      => nil,
                                                                :type       => nil,
                                                                :params     => {},
                                                                :no_pruning => [] ),
                                 :flex_models      => [],
                                 :config_file      => './config/flex.yml',
                                 :flex_dir         => './flex',
                                 :http_client      => HttpClients::Loader.new_http_client

  # shorter alias
  Conf = Configuration

  Conf.instance_eval do
    def configure
      yield self
    end

    # temprary deprecation warnings
    def base_uri
      Utils.deprecate 'Flex::Configuration.base_uri', 'Flex::Configuration.http_client.base_uri'
      http_client.base_uri
    end
    def base_uri=(val)
      Utils.deprecate 'Flex::Configuration.base_uri=', 'Flex::Configuration.http_client.base_uri='
      http_client.base_uri = val
    end
    def http_client_options
      Utils.deprecate 'Flex::Configuration.http_client_options', 'Flex::Configuration.http_client.options'
      http_client.options
    end
    def http_client_options=(val)
      Utils.deprecate 'Flex::Configuration.http_client_options=', 'Flex::Configuration.http_client.options='
      http_client.options = val
    end
    def raise_proc
      Utils.deprecate 'Flex::Configuration.raise_proc', 'Flex::Configuration.http_client.raise_proc'
      http_client.raise_proc
    end
    def raise_proc=(val)
      Utils.deprecate 'Flex::Configuration.raise_proc=', 'Flex::Configuration.http_client.raise_proc='
      http_client.raise_proc = val
    end
  end

end
