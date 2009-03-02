require 'rubygems'
require 'sexp_processor'

module Reek

  class ObjectRefs  # :nodoc:
    def initialize
      @refs = Hash.new(0)
      record_reference_to_self
    end
    
    def record_reference_to_self
      record_ref(SELF_REF)
    end

    def record_ref(exp)
      type = exp[0]
      case type
      when :gvar
        return
      when :self
        record_reference_to_self
      else
        @refs[exp] += 1
      end
    end

    def refs_to_self
      @refs[SELF_REF]
    end

    def max_refs
      @refs.values.max or 0
    end

    # TODO
    # Should be moved to Hash; but Hash has 58 methods, and there's currently
    # no way to turn off that report; which would therefore make the tests fail
    def max_keys
      max = max_refs
      @refs.reject {|key,val| val != max}.keys
    end

    def self_is_max?
      max_keys.length == 0 || @refs[SELF_REF] == max_refs
    end

  private
    
    SELF_REF = Sexp.from_array([:lit, :self])

  end
end
