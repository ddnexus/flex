module Flex
  class ProgBar

    attr_reader :pbar, :total_count

    def initialize(total_count, batch_size=nil, prefix_message=nil)
      @total_count      = total_count
      @successful_count = 0
      @failed_count     = 0
      @pbar             = ::ProgressBar.new('processing...', total_count)
      @pbar.clear
      @pbar.bar_mark = '|'
      puts '_' * @pbar.send(:get_term_width)
      message = "#{prefix_message}Processing #{total_count} documents"
      message << " in batches of #{batch_size}:" unless batch_size.nil?
      puts message
      @pbar.send(:show)
    end

    def process_result(result, inc)
      Configuration.logger.error "[FLEX] Failed load:\n#{result.failed.to_yaml}" unless result.failed.size == 0
      @failed_count     += result.failed.size
      @successful_count += result.successful.size
      @pbar.inc(inc)
    end

    def finish
      @pbar.finish
      puts "Processed #{@total_count}. Successful #{@successful_count}. Skipped #{@total_count - @successful_count - @failed_count}. Failed #{@failed_count}."
      puts "See the log for the details about the failed import." unless @failed_count == 0
    end

  end
end
