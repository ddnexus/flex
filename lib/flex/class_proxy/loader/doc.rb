module Flex
  module ClassProxy
    module Loader
      module Doc

        def doc(*names)
          names = templates.keys if names.empty?
          doc = "\n"
          names.each do |name|
            next unless templates.include?(name)
            block = ''
            temp = templates[name]
            meth_call = [context, name].join('.')
            block << <<-meth_call
########## #{meth_call} ##########
#{'-' * temp.class.to_s.length}
#{temp.class}
#{temp.to_source}
meth_call
            temp.partials.each do |par_name|
              par = partials[par_name]
              block << <<-partial
#{'-' * par.class.to_s.length}
#{par.class}
#{par.to_source}
partial
            end
            block << "\nUsage:\n"
            block << build_usage(meth_call, temp)
            block << "\n "
            doc << block.split("\n").map{|l| '#  ' + l}.join("\n")
            doc << <<-meth.gsub(/^ {14}/m,'')

def #{meth_call}(*vars)
  ## this is a stub, used for reference
  super
end

meth
          end
          puts doc
        end

        def info(*names)
          Utils.deprecate 'flex.info', 'flex.doc'
          doc *names
        end

        def usage(name)
          meth_call = [context, name].join('.')
          puts build_usage(meth_call, templates[name])
        end

      private

        def build_usage(meth_call, temp)
          variables = temp.instance_eval do
                        interpolate
                        @base_variables.deep_merge @host_flex && @host_flex.variables, @temp_variables
                      end
          all_tags  = temp.tags + temp.partials
          lines     = all_tags.map do |t|
                        comments = 'partial' if t.to_s[0] == '_'
                        line = ['', t.inspect]
                        line + if variables.has_key?(t)
                                 ["#{variables[t].inspect},", comments_to_s(comments)]
                               else
                                 ["#{to_code(t)},", comments_to_s(comments, 'required')]
                               end
                      end
          lines.sort! { |a,b| b[3] <=> a[3] }
          lines.first[0] = meth_call
          lines.last[2].chop!
          max = lines.transpose.map { |c| c.map(&:length).max }
          lines.map { |line| "%-#{max[0]}s %-#{max[1]}s => %-#{max[2]}s  %s" % line }.join("\n")
        end

        def comments_to_s(*comments)
          comments = comments.compact
          return '' if comments == []
          "# #{comments.join(' ')}"
        end

        def to_code(name)
          keys = name.to_s.split('.').map{|s| s =~ /^[0..9]+$/ ? s.to_i : s.to_sym}
          code = keys.shift.to_s
          return code if keys.empty?
          keys.each{|k| code << "[#{k.inspect}]"}
          code
        end

      end
    end
  end
end
