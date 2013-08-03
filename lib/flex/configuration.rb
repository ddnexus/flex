module Flex

  Configuration = OpenStruct.new :result_extenders => [ Result::Document,
                                                        Result::Search,
                                                        Result::MultiGet,
                                                        Result::Bulk ],
                                 :logger           => Logger.new(STDERR),
                                 :variables        => Vars.new( :index      => nil,
                                                                :type       => nil,
                                                                :params     => {},
                                                                :no_pruning => [] ),
                                 :config_file      => './config/flex.yml',
                                 :flex_dir         => './flex',
                                 :http_client      => HttpClients::Loader.new_http_client,
                                 :redis            => $redis || defined?(::Redis) && ::Redis.current

  # shorter alias
  Conf = Configuration

  Conf.instance_eval do
    def configure
      yield self
    end
  end

end
