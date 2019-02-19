require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/subclassed_from_core_class'

RSpec.describe Reek::SmellDetectors::SubclassedFromCoreClass do
  it 'reports the right values' do
    src = <<-RUBY
      class Alfa < Hash
      end
    RUBY

    expect(src).to reek_of(:SubclassedFromCoreClass,
                           lines:    [1],
                           context:  'Alfa',
                           message:  "inherits from core class 'Hash'",
                           source:   'string',
                           ancestor: 'Hash')
  end

  it 'reports when inheriting from a core class inside a module' do
    src = <<-RUBY
      module Alfa
        class Bravo < Hash
        end
      end
    RUBY

    expect(src).to reek_of(:SubclassedFromCoreClass, context: 'Alfa::Bravo')
  end

  it 'does not report when not inheriting from a core class' do
    src = <<-RUBY
      class Alfa
      end
    RUBY

    expect(src).not_to reek_of(:SubclassedFromCoreClass)
  end

  it 'does not report on coincidental core class names in other namespaces' do
    src = <<-RUBY
      class Alfa < Bravo::Array
      end
    RUBY

    expect(src).not_to reek_of(:SubclassedFromCoreClass)
  end

  it 'reports if inner class inherit from a core class' do
    src = <<-RUBY
      class Alfa
        Bravo = Class.new(Array)
      end
    RUBY

    expect(src).to reek_of(:SubclassedFromCoreClass, context: 'Alfa::Bravo')
  end

  it 'reports class which inherits from core class via Class.new' do
    src = 'Alfa = Class.new(Array)'
    expect(src).to reek_of(:SubclassedFromCoreClass)
  end

  it 'does not report class which inherits from allowed class via Class.new' do
    src = 'Alfa = Class.new(StandardError)'
    expect(src).not_to reek_of(:SubclassedFromCoreClass)
  end

  it 'does not report classes created with Struct.new' do
    src = "Alfa = Struct.new('Array')"
    expect(src).not_to reek_of(:SubclassedFromCoreClass)
  end

  it 'does not report class created by another class constructor taking a core class as argument' do
    src = 'Charlie = Delta.new(Array)'
    expect(src).not_to reek_of(:SubclassedFromCoreClass)
  end
end
