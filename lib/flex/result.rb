module Flex
  class Result < ::Hash

    attr_reader :template, :response
    attr_accessor :variables

    def initialize(template, variables, response, result=nil)
      @template  = template
      @variables = variables
      @response  = response
      replace result || !response.body.empty? && MultiJson.decode(response.body) || return
      C11n.result_extenders.each do |ext|
        next if ext.respond_to?(:should_extend?) && !ext.should_extend?(self)
        extend ext
      end
    end

    def to_flex_result(force=false)
      return self if variables[:context].nil? || variables[:raw_result] &&! force
      variables[:context].respond_to?(:flex_result) ? variables[:context].flex_result(self) : self
    end

  end
end
