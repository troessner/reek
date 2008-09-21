$:.unshift File.dirname(__FILE__)

require 'reek/checker'
require 'reek/smells'
require 'set'

module Reek

  class ObjectRefs

    def initialize
      @refs = Hash.new(0)
    end
    
    def record_reference_to_self
      record_ref Sexp.from_array([:lit, :self])
    end

    def record_ref(exp)
      @refs[exp] += 1
    end

    def refs_to_self
      @refs[Sexp.from_array([:lit, :self])]
    end

    # TODO
    # Should be moved to Hash; but Hash has 58 methods, and there's currently
    # no way to turn off that report; which would therefore make the tests fail
    def max_keys
      max = @refs.values.max or 0
      @refs.keys.select { |key| @refs[key] == max }
    end

    def self_is_max?
      max_keys.include?(Sexp.from_array([:lit, :self]))
    end
  end
end
