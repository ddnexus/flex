module Flex
  class Vars < Struct::Hash

    class Prunable
      class << self
        def to_s; '' end
        alias_method :===, :==
      end
    end

    alias_method :hash_new, :initialize

    def variables_new(*hashes)
      start = hash_new do |hash, key|
                if key[-1] == '!'
                  klass = (key[0] == '_' ? Struct::Array : Struct::Hash)
                  hash[clean_key(key)] = klass.new
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
      keys.select{|k| k[0] == '_' && !prunable?(k)}.each do |name|
        raise ArgumentError, "Array expected as :#{name} (got #{self[name].inspect})" \
              unless self[name].is_a?(Array)
        self[name] = self[name].map {|v| host_flex.partials[name].interpolate(self, v)}
      end
      self[:index] = self[:index].uniq.join(',') if self[:index].is_a?(Array)
      self[:type]  = self[:type].uniq.join(',')  if self[:type].is_a?(Array)
      # so you can pass :fields => [:field_one, :field_two]
      self[:params!].each{|k,v| self[:params][k] = v.uniq.join(',') if v.is_a?(Array)}
      if self[:page]
        self[:page] = self[:page].to_i
        self[:page] == 1 unless self[:page] > 0
        self[:params][:from] ||= ((self[:page] - 1) * (self[:params][:size] || 10)).ceil
      else
        self[:page] = 1
      end
      self
    end

    # returns Prunable if the value is nil, [], {} (called from stringified)
    def prunable?(key)
      val = get_val(key)
      return val if self[:no_pruning].include?(key)
      (val.nil? || val == '' || val == [] || val == {}) ? Prunable : val
    end

    private

    # allows to fetch values for tag names like 'a.3.c' fetching vars[:a][3][:c]
    def get_val(key)
      return self[key] if self.has_key?(key) # to make tag defaults work see Tags#variables
      keys = key.to_s.split('.').map{|s| s =~ /^[0..9]+$/ ? s.to_i : s.to_sym}
      keys.inject(self, :fetch)
    rescue NoMethodError, KeyError
      raise MissingVariableError, "required variables #{key.inspect} missing."
    end


  end
  Variables = Vars
end


