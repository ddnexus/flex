module Flex
  class Vars < Struct::Hash

    class Prunable
      class << self
        def to_s; '' end
        alias_method :===, :==
      end
    end

    PRUNABLES = [ nil, '', {}, [], false ]

    def initialize(*hashes)
      deep_merge! super(), *hashes
    end

    def add(*hashes)
      Utils.deprecate 'Flex::Variables#add', 'Flex::Variables#deep_merge!'
      replace deep_merge(*hashes)
    end

    def finalize(host_flex)
      keys.select{|k| k[0] == '_'}.each do |name| # partials
        val = self[name]
        next if PRUNABLES.include?(val)
        val = [{}] if val == true
        raise ArgumentError, "Array expected as :#{name} (got #{val.inspect})" \
              unless val.is_a?(Array)
        self[name] = val.map {|v| host_flex.partials[name].interpolate(self, v)}
      end
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

    def self.prune_blanks(obj)
      prune(obj, *PRUNABLES) || {}
    end

    # prunes the branch when the leaf is Prunable
    # and compact.flatten the Array values
    def self.prune(obj, *prunables)
      case
      when prunables.include?(obj)
        obj
      when obj.is_a?(::Array)
        return obj if obj.empty?
        ar = []
        obj.each do |i|
          pruned = prune(i, *prunables)
          next if prunables.include?(pruned)
          ar << pruned
        end
        a = ar.compact.flatten
        a.empty? ? prunables.first : a
      when obj.is_a?(::Hash)
        return obj if obj.empty?
        h = {}
        obj.each do |k, v|
          pruned = prune(v, *prunables)
          next if prunables.include?(pruned)
          h[k] = pruned
        end
        h.empty? ? prunables.first : h
      else
        obj
      end
    end

    # returns Prunable if the value is nil, [], {} (called from stringified)
    def prunable?(key)
      val = get_val(key)
      return val if self[:no_pruning].include?(key)
      PRUNABLES.include?(val) ? Prunable : val
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
  Variables = Vars
end


