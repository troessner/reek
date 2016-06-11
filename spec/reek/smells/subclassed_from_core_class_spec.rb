require_relative '../../spec_helper'
require_lib 'reek/smells/subclassed_from_core_class'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::SubclassedFromCoreClass do
  let(:detector) { described_class.new }

  it_should_behave_like 'SmellDetector'

  it 'should not report if the class has no ancestor' do
    src = <<-EOS
      class Dummy
      end
    EOS
    expect(src).to_not reek_of(:SubclassedFromCoreClass)
  end

  it 'should report if we inherit from a core class' do
    src = <<-EOS
      class Dummy < Array
      end
    EOS
    expect(src).to reek_of(:SubclassedFromCoreClass, ancestor: "Array")
  end

  it 'should not report on coincidental core class names in other namespaces' do
    src = <<-EOS
      class Dummy < My::Array
      end
    EOS
    expect(src).to_not reek_of(:SubclassedFromCoreClass)
  end

  it 'should report if we inherit from a core class from within a namespaced class' do
    src = <<-EOS
      module Namespace
        class Dummy < Array
        end
      end
    EOS
    expect(src).to reek_of(:SubclassedFromCoreClass, ancestor: "Array")
  end

  it 'should report if we inherit from a core class using Class#new' do
    src = "Dummy = Class.new(Array)"
    expect(src).to reek_of(:SubclassedFromCoreClass, ancestor: "Array")
  end

  it 'should report if we inherit from a core class using Class#new within a namespaced class' do
    src = <<-EOS
      module Namespace
        class Dummy
          Dummiest = Class.new(Array)
        end
      end
    EOS
    expect(src).to reek_of(:SubclassedFromCoreClass, ancestor: "Array")
  end
end
