require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/simulated_polymorphism'

include Reek::Smells

describe SimulatedPolymorphism do
  it 'should report 3 similar conditions in a class' do
    src = <<EOS
class Scrunch
  def first
    return @field == :sym ? 0 : 3;
  end
  def second
    if @field == :sym
      @other += " quarts"
    end
  end
  def third
    raise 'flu!' unless @field == :sym
  end
end
EOS

    src.should reek_only_of(:SimulatedPolymorphism, /@field == :sym/)
  end

  # Don't forget to include 'case' statements!

  # And count code in superclasses, if we have it
end
