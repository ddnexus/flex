module Flex
  module HttpClients
    class RestClient < Base

      def request(method, path, data=nil)
        url  = "#{base_uri}#{path}"
        opts = options.merge( :method  => method.to_s.downcase.to_sym,
                              :url     => url,
                              :payload => data )
        response = ::RestClient::Request.new( opts ).execute
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
