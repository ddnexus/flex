module Flex
  module HttpClients
    module RestClient
      extend self

      def request(method, path, data=nil)
        options = Configuration.http_client_options
        url     = "#{Configuration.base_uri}#{path}"
        args    = options.merge( :method  => method.to_s.downcase.to_sym,
                                 :url     => url,
                                 :payload => data )
        response = ::RestClient::Request.new( args ).execute
        extend_response(response, url)

      rescue ::RestClient::ExceptionWithResponse => e
        extend_response(e.response, url)
      end

    private

      def extend_response(response, url)
        response.extend ResponseExtension
        response.url = url
        response
      end

      module ResponseExtension
        attr_accessor :url

        def status
          code.to_i
        end

      end

    end
  end
end
