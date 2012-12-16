module Flex
  class Variables < Struct::Hash

    def initialize(*hashes)
      deep_merge! super(), *hashes
    end

    def add(*hashes)
      Utils.deprecate 'Flex::Variables#add', 'Flex::Variables#deep_merge!'
      replace deep_merge(*hashes)
    end

    def finalize
      self[:index] = self[:index].uniq.join(',') if self[:index].is_a?(Array)
      self[:type]  = self[:type].uniq.join(',')  if self[:type].is_a?(Array)
      # so you can pass :fields => [:field_one, :field_two]
      self[:params!].each{|k,v| self[:params][k] = v.uniq.join(',') if v.is_a?(Array)}
      if self[:page]
        self[:page] = self[:page].to_i
        self[:page] = 1 unless self[:page] > 0
        self[:params][:from] ||= ((self[:page] - 1) * (self[:params][:size] || 10)).ceil unless self[:page] == 1
      else
        self[:page] = 1
      end
      self
    end

    # returns Prunable::Value if the value is in VALUES (called from stringified)
    def get_prunable(key)
      val = get_val(key)
      return val if self[:no_pruning].include?(key)
      Prunable::VALUES.include?(val) ? Prunable::Value : val
    end

    private

    # allows to fetch values for tag names like 'a.3.c' fetching vars[:a][3][:c]
    def get_val(key)
      return self[key] if has_key?(key) # to make tag defaults work see Tags#variables
      keys = key.to_s.split('.').map{|s| s =~ /^[0..9]+$/ ? s.to_i : s.to_sym}
      keys.inject(self, :fetch)
    rescue NoMethodError, KeyError
      raise MissingVariableError, "required variables #{key.inspect} missing."
    end

  end
  # shorter alias
  Vars = Variables
end


