module Flex
  class Template
    module Info

      def info(*names)
        names = templates.keys if names.empty?
        info = "\n"
        names.each do |name|
          next unless templates.include?(name)
          block = ''
          temp = templates[name]
          meth_call = [host_class, name].join('.')
          block << "########## #{meth_call} ##########\n\n#{'-' * temp.class.to_s.length}\n#{temp.class}\n#{temp.to_flex(name)}\n"
          temp.partials.each do |par_name|
            par = partials[par_name]
            block << "#{'-' * par.class.to_s.length}\n#{par.class}\n#{par.to_flex(par_name)}\n"
          end
          block << "\nUsage:\n"
          block << usage(meth_call, temp)
          block << "\n "
          info  << block.split("\n").map{|l| '#  ' + l}.join("\n")
          info  <<  "\ndef #{meth_call}(vars={})\n  # this is a stub, used for reference\nend\n\n\n"
        end
        info
      end

    private

      def usage(meth_call, temp)
        all_tags = temp.tags + temp.partials
        lines = all_tags.map do |t|
          comments = 'partial' if t.to_s.match(/^_/)
          ['', t.to_s] + (temp.variables.has_key?(t) ? ["#{temp.variables[t].inspect},", comments_to_s(comments)] : ["#{t},", comments_to_s(comments, 'required')])
        end
        lines.sort! { |a,b| b[3] <=> a[3] }
        lines.first[0] = meth_call
        lines.last[2].chop!
        max = lines.transpose.map { |c| c.map(&:length).max }
        lines.map { |line| "%-#{max[0]}s :%-#{max[1]}s => %-#{max[2]}s  %s" % line }.join("\n")
      end

      def comments_to_s(*comments)
        comments = comments.compact
        return '' if comments == []
        "# #{comments.join(' ')}"
      end

    end
  end
end
