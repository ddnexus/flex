module Flex
  class Template
    module Logger

    private

      def log_render(int, path, encoded_data, result)
        log = Configuration.log
        return unless (int && Configuration.logger.level == ::Logger::DEBUG && log.enable)
        h = {}
        if log.variables
          h[:variables] = int[:vars]
        end
        if log.request
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
        if log.result
          h[:result] = result if result
        end
        log_string = log.to_curl ? to_curl_string(h[:request]) : h.to_yaml
        log_string = format(log_string) unless log.to_curl
        Configuration.logger.debug  Dye.dye("Rendered #{caller_line}\n", :blue, :bold) + log_string
      end

      def caller_line
        method_name = @host_flex && @name && "#{@host_flex.context}.#@name"
        line = caller.find{|l| l !~ /#{LIB_PATH}/}
        ll = ''
        ll << "#{method_name} from " if method_name
        ll << "#{line}"
        ll
      end

      def to_curl_string(h)
        pretty = h[:path] =~ /\?/ ? '&pretty=1' : '?pretty=1'
        curl =  %(curl -X#{method} "#{Configuration.base_uri}#{h[:path]}#{pretty}")
        if h[:data]
          data = h[:data].is_a?(String) ? h[:data] : MultiJson.encode(h[:data], :pretty => true)
          curl << %( -d '\n#{data}\n')
        end
        curl
      end

      def format(string)
        string.split("\n").map do |l|
          case l
          when /^---$/
          when /^ /
            Dye.dye(l, :blue)
          else
            Dye.dye(l, :magenta, :bold) + (Dye.color ? Dye.sgr(:blue) : '')
          end
        end.compact.join("\n") + "\n"
      end

    end
  end
end
