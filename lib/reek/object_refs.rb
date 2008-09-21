$:.unshift File.dirname(__FILE__)

require 'sexp'

module Reek

  class ObjectRefs
    SELF_REF = Sexp.from_array([:lit, :self])

    def initialize
      @refs = Hash.new(0)
    end
    
    def record_reference_to_self
      record_ref(SELF_REF)
    end

    def record_ref(exp)
      @refs[exp] += 1
#      puts "record_ref(#{exp.inspect}) -> #{@refs.inspect}"
    end

    def refs_to_self
      @refs[SELF_REF]
    end

    # TODO
    # Should be moved to Hash; but Hash has 58 methods, and there's currently
    # no way to turn off that report; which would therefore make the tests fail
    def max_keys
      max = @refs.values.max or 0
      @refs.keys.select { |key| @refs[key] == max }
    end

    def self_is_max?
      max_keys.include?(SELF_REF)
    end
  end
end
