module Flex
  class Variables < Struct::Hash

    def initialize(*hashes)
      deep_merge! super(), *hashes
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
      val = fetch_nested(key)
      return val if self[:no_pruning].include?(key)
      Prunable::VALUES.include?(val) ? Prunable::Value : val
    end

    # allows to store keys like 'a.3.c' into vars[:a][3][:c]
    def store_nested(key, value)
      var = unnest(key).reverse.inject(value) do |memo,k|
              if k.is_a?(Symbol)
                {k => memo}
              else
                ar = []
                ar[k] = memo
                ar
              end
            end
      deep_merge! var
    end

    # allows to fetch values for tag names like 'a.3.c' fetching vars[:a][3][:c]
    def fetch_nested(key)
      unnest(key).inject(self, :fetch)
    rescue NoMethodError, KeyError
      raise MissingVariableError, "the required #{key.inspect} variable is missing."
    end

    private

    def unnest(key)
      key.to_s.split('.').map{|s| s =~ /^\d+$/ ? s.to_i : s.to_sym}
    end

  end
  # shorter alias
  Vars = Variables
end


