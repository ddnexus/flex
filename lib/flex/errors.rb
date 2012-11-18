module Flex

  class ArgumentError          < ArgumentError; end
  class SourceError            < StandardError; end
  class MissingPartialError    < StandardError; end
  class DocumentMappingError   < StandardError; end
  class MissingIndexEntryError < StandardError; end
  class ExistingIndexError     < StandardError; end
  class MissingHttpClientError < StandardError; end
  class MissingParentError     < StandardError; end
  class MissingVariableError   < StandardError; end

  class HttpError < StandardError

    attr_reader :response

    def initialize(response, caller_line=nil)
      @response    = response
      @caller_line = caller_line
    end

    def status
      response.status
    end

    def body
      response.body
    end

    def to_s
      log = "#{@caller_line}\n" if @caller_line
      "#{log}#{status}: #{body}"
    end

    def to_hash
      MultiJson.decode response.body
    rescue MultiJson::DecodeError
      {}
    end

  end

end
