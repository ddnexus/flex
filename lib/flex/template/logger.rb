module Flex
  class Template
    module Logger

    def caller_line
      caller.find{|l| l !~ /(#{LIB_PATHS.join('|')})/}
    end

    private

      def template_name
        @host_flex && @name && "#{@host_flex.context}.#@name" || 'template'
      end

      def log_render(int, path, encoded_data, result)
        logger = Conf.logger
        return unless logger.is_a?(Flex::Logger)
        logger.info Dye.dye("Rendered #{template_name} from: #{caller_line}", :blue, :bold)
        return unless logger.level == ::Logger::DEBUG

        h = {}
        if logger.debug_variables
          h[:variables] = int[:vars] if int
        end
        if logger.debug_request
          h[:request] = {}
          h[:request][:method] = method
          h[:request][:path]   = path
          h[:request][:data]   = begin
                                   MultiJson.decode(encoded_data) unless encoded_data.nil?
                                 rescue MultiJson::DecodeError
                                   encoded_data
                                 end
          h[:request].delete(:data) if h[:request][:data].nil?
        end
        if logger.debug_result
          h[:result] = result if result
        end
        logger.debug logger.curl_format ? curl_format(h[:request]) : yaml_format(h)
      end

      def curl_format(h)
        pretty = h[:path] =~ /\?/ ? '&pretty=1' : '?pretty=1'
        curl =  %(curl -X#{method} "#{Conf.base_uri}#{h[:path]}#{pretty}")
        if h[:data]
          data = h[:data].is_a?(String) ? h[:data] : MultiJson.encode(h[:data], :pretty => true)
          curl << %( -d '\n#{data}\n')
        end
        curl
      end

      def yaml_format(hash)
        hash.to_yaml.split("\n").map do |l|
          case l
          when /^---$/
          when /^( |-)/
            Dye.dye(l, :blue)
          when  /^:(variables|request|result)/
            Dye.dye(l, :magenta, :bold) + (Dye.color ? Dye.sgr(:blue) : '')
          end
        end.compact.join("\n") + "\n"
      end

    end
  end
end
