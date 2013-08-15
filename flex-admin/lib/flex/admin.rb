module Flex
  module Admin

    class Tasks

      attr_reader :options

      def initialize(overrides={})
        options = Flex::Utils.env2options *default_options.keys

        options[:size]       = options[:size].to_i       if options[:size]
        options[:timeout]    = options[:timeout].to_i    if options[:timeout]
        options[:batch_size] = options[:batch_size].to_i if options[:batch_size]
        options[:index_map]  = Hash[options[:index_map].split(',').map{|i|i.split(':')}] if options[:index_map] && options[:index_map].is_a?(String)

        @options = default_options.merge(options).merge(overrides)
      end

      def default_options
        @default_options ||= { :file       => './flex.dump',
                               :index      => Conf.variables[:index],
                               :type       => Conf.variables[:type],
                               :scroll     => '5m',
                               :size       => 50,
                               :timeout    => 20,
                               :batch_size => 1000,
                               :verbose    => true,
                               :index_map  => nil }
      end

      def dump_to_file(cli=false)
        vars = { :index => cli ? options[:index] : (options[:index] || Flex::Tasks.new.config_hash.keys),
                 :type  => options[:type] }
        if options[:verbose]
          total_hits  = Flex.count(vars)['count'].to_i
          total_count = 0
          pbar        = ProgBar.new(total_hits)
          dump_stats  = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = 0 } }
          file_size   = 0
        end
        vars.merge! :params => { :scroll => options[:scroll],
                                 :size   => options[:size],
                                 :fields => '_source,*' }

        file = options[:file].is_a?(String) ? File.open(options[:file], 'wb') : options[:file]
        path = file.path

        Flex.dump_all(vars) do |batch|
          bulk_string = ''
          batch.each do |document|
            dump_stats[document['_index']][document['_type']] += 1 if options[:verbose]
            bulk_string << Flex.build_bulk_string(document)
          end
          file.puts bulk_string
          if options[:verbose]
            total_count += batch.size
            pbar.pbar.inc(batch.size)
          end
        end
        file_size = file.size if options[:verbose]
        file.close

        if options[:verbose]
          formatted_file_size = file_size.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse
          pbar.pbar.finish
          puts "\n***** WARNING: Expected document to dump: #{total_hits}, dumped: #{total_count}. *****" \
               unless total_hits == total_count
          puts "\nDumped #{total_count} documents to #{path} (size: #{formatted_file_size} bytes)"
          puts dump_stats.to_yaml
        end
      end

      def load_from_file
        Configuration.http_client.options[:timeout] = options[:timeout]
        chunk_size  = options[:batch_size] * 2 # 2 lines per doc
        bulk_string = ''
        file        = options[:file].is_a?(String) ? File.open(options[:file]) : options[:file]
        path        = file.path
        if options[:verbose]
          line_count = 0
          file.lines { line_count += 1 }
          file.rewind
          puts "\nLoading from #{path}...\n"
          pbar = ProgBar.new(line_count / 2, options[:batch_size])
        end
        file.lines do |line|
          bulk_string << (options[:index_map] ? map_index(line) : line)
          if (file.lineno % chunk_size) == 0
            result = Flex.post_bulk_string :bulk_string => bulk_string
            bulk_string  = ''
            pbar.process_result(result, options[:batch_size]) if options[:verbose]
          end
        end
        # last chunk
        unless bulk_string == ''
          result = Flex.post_bulk_string :bulk_string => bulk_string
          pbar.process_result(result, (file.lineno % chunk_size) / 2) if options[:verbose]
        end
        file.close
        pbar.finish if options[:verbose]
      end

    private

      def map_index(line)
        joined_keys = options[:index_map].keys.join('|')
        line.sub(/"_index":"(#{joined_keys})"/) do |match_string|
          options[:index_map].has_key?($1) ? %("_index":"#{options[:index_map][$1]}") : match_string
        end
      end

    end
  end
end
