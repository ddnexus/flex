module Flex
  module HttpClients
    class Patron < Base

      def request(method, path, data=nil)
        # patron would raise an error for :post and :put requests with no data
        # and elasticsearch ignores the data when it expects no data,
        # so we silence patron by adding some dummy data
        data = {} if (method == 'POST' || method == 'PUT') && data.nil?
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
