module Flex
  module HttpClients
    class Patron < Base

      def request(method, path, data=nil)
        opts = options.merge(:data => data)
        session.request method.to_s.downcase.to_sym, path, {}, opts
      rescue ::Patron::TimeoutError
        session.request method.to_s.downcase.to_sym, path, {}, opts
      end

    private

      def session
        Thread.current[:flex_patron_session] ||= begin
                                                   sess                       = ::Patron::Session.new
                                                   sess.headers['User-Agent'] = "flex-#{Flex::VERSION}"
                                                   sess.base_url              = base_uri
                                                   sess
                                                 end
      end

    end
  end
end
