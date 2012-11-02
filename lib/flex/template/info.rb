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
          block << <<-meth_call
########## #{meth_call} ##########

#{'-' * temp.class.to_s.length}
#{temp.class}
#{temp.to_flex(name)}
meth_call
          temp.partials.each do |par_name|
            par = partials[par_name]
            block << <<-partial
#{'-' * par.class.to_s.length}
#{par.class}
#{par.to_flex(par_name)}
partial
          end
          block << "\nUsage:\n"
          block << usage(meth_call, temp)
          block << "\n "
          info  << block.split("\n").map{|l| '#  ' + l}.join("\n")
          info  <<  <<-meth

def #{meth_call}(vars={})
  ## this is a stub, used for reference
end


meth
        end
        info
      end

    private

      def usage(meth_call, temp)
        all_tags = temp.tags + temp.partials
        lines = all_tags.map do |t|
          comments = 'partial' if t.to_s.match(/^_/)
          ['', t.to_s] + (temp.variables.has_key?(t) ? ["#{temp.variables[t].inspect},", comments_to_s(comments)] \
                                                     : ["#{t},", comments_to_s(comments, 'required')])
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
