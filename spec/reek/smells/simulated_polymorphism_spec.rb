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

  it 'should include case statements in the count' do
    src = <<EOS
class Scrunch
  def first
    return @field ? 0 : 3;
  end
  def second
    case @field
    when :sym
      @other += " quarts"
    end
  end
  def third
    raise 'flu!' unless @field
  end
end
EOS

    src.should reek_only_of(:SimulatedPolymorphism, /@field/)
  end

  # And count code in superclasses, if we have it
end
