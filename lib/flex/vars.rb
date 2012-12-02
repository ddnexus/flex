module Flex
  class Vars < Structure::Hash


    alias_method :hash_new, :initialize

    def variables_new(*hashes)
      start = hash_new do |hash, key|
                if key[0] == '_'
                  hash[key] = Structure::Array.new
                end
              end
      deep_merge! start, *hashes
    end

    alias_method :initialize, :variables_new

    def add(*hashes)
      Utils.deprecate 'Flex::Variables#add', 'Flex::Variables#deep_merge!'
      replace deep_merge(*hashes)
    end

    def final_process(host_flex)
      # partials
      keys.select{|k| k[0] == '_'}.each do |name|
        next if self[name].nil? # may come from assigned values
        raise ArgumentError, "Array expected as :#{name} (got #{self[name].inspect})" \
                unless self[name].is_a?(Array)
        self[name] = self[name].map {|v| host_flex.partials[name].interpolate(self, v)}
      end
      self[:index] = self[:index].uniq.join(',') if self[:index].is_a?(Array)
      self[:type]  = self[:type].uniq.join(',')  if self[:type].is_a?(Array)
      self[:params] ||= Structure::Hash.new
      # so you can pass :fields => [:field_one, :field_two]
      params = self[:params]
      params.each{|k,v| self[:params][k] = v.uniq.join(',') if v.is_a?(Array)}
      if self[:page]
        self[:page] = self[:page].to_i
        self[:page] == 1 unless self[:page] > 0
        self[:params][:from] ||= ((self[:page] - 1) * (self[:params][:size] || 10)).ceil
      else
        self[:page] = 1
      end
      self
    end

  end
  Variables = Vars
end


