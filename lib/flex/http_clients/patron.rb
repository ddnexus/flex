module Flex
  module HttpClients
    module Patron
      extend self

      def request(method, path, data=nil, options={})
        options = Utils.deep_merge_hashes(Configuration.http_client_options, options)
        options = options.merge(:data => data) if data
        session.request method.to_s.downcase.to_sym, path, {}, options
      rescue ::Patron::TimeoutError
        session.request method.to_s.downcase.to_sym, path, {}, options
      end

    private

      def session
        Thread.current[:flex_patron_session] ||= begin
                                                   sess                       = ::Patron::Session.new
                                                   sess.headers['User-Agent'] = "flex-#{Flex::VERSION}"
                                                   sess.base_url              = Configuration.base_uri
                                                   sess
                                                 end
      end

    end
  end
end
