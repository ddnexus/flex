module Flex
  class Struct < OpenStruct

    def configure
      yield self
    end

  end

  class LogStruct < Struct

    # force color in console (used with jruby)
    def color=(bool)
      Dye.color = bool
    end

    def color
      Dye.color?
    end

  end

  extend self

  def load_http_client
    if Gem::Specification.respond_to?(:find_all_by_name)
      case
        # terrible way to check whether a gem is available.
        # Gem.available? was just perfect: that's probably the reason it has been deprecated!
        # https://github.com/rubygems/rubygems/issues/176
      when Gem::Specification::find_all_by_name('patron').any?
        require 'patron'
        Flex::HttpClients::Patron
      when Gem::Specification::find_all_by_name('rest-client').any?
        require 'rest-client'
        Flex::HttpClients::RestClient
      end
    else
      case
      when Gem.available?('patron')
        require 'patron'
        Flex::HttpClients::Patron
      when Gem.available?('rest-client')
        require 'rest-client'
        Flex::HttpClients::RestClient
      end
    end
  end
  private :load_http_client

  Configuration = Struct.new :base_uri            => 'http://localhost:9200',
                             :result_extenders    => [ Flex::Result::Document,
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
                             :http_client         => load_http_client,
                             :http_client_options => {},
                             :log                 => LogStruct.new( :enable    => true,
                                                                    :variables => true,
                                                                    :request   => true,
                                                                    :result    => true,
                                                                    :to_curl   => false ),
                             :raise_proc          => proc{|response| response.status >= 400}


end
