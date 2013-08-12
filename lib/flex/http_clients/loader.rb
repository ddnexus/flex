module Flex
  module HttpClients

    class Dummy
      def request(*)
        raise MissingHttpClientError,
              'you should install the gem "patron" (recommended for performances) or "rest-client", ' +
              'or provide your own http-client interface and set Flex::Configuration.http_client'
      end
    end

    module Loader

      extend self

      def new_http_client
        if Gem::Specification.respond_to?(:find_all_by_name)
          case
            # terrible way to check whether a gem is available.
            # Gem.available? was just perfect: that's probably the reason it has been deprecated!
            # https://github.com/rubygems/rubygems/issues/176
          when Gem::Specification::find_all_by_name('patron').any?      then require_patron
          when Gem::Specification::find_all_by_name('rest-client').any? then require_rest_client
          else Dummy.new
          end
        else
          case
          when Gem.available?('patron')      then require_patron
          when Gem.available?('rest-client') then require_rest_client
          else Dummy.new
          end
        end
      end

    private

      def require_patron
        require 'patron'
        require 'flex/http_clients/patron'
        Patron.new
      end

      def require_rest_client
        require 'rest-client'
        require 'flex/http_clients/rest_client'
        RestClient.new
      end

    end
  end
end
