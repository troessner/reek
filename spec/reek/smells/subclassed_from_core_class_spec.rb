require_relative '../../spec_helper'
require_lib 'reek/smells/subclassed_from_core_class'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::SubclassedFromCoreClass do
  let(:detector) { described_class.new }

  it_should_behave_like 'SmellDetector'

  context 'report' do
    context 'smell line' do
      context 'single class' do
        it 'should report the core class in the message' do
          src = <<-EOS
            class Dummy < Hash
            end
          EOS

          expect(src).to reek_of(:SubclassedFromCoreClass, lines: [1])
        end
      end

      context 'class inside a module' do
        it 'should report the core class in the message' do
          src = <<-EOS
            module Namespace
              class Dummy < Hash
              end
            end
          EOS

          expect(src).to reek_of(:SubclassedFromCoreClass, lines: [2])
        end
      end
    end

    context 'smell message' do
      context 'Array' do
        it 'should report the core class in the message' do
          src = <<-EOS
            class Dummy < Array
            end
          EOS

          expect(src).to reek_of(:SubclassedFromCoreClass, message: 'inherits from a core class (Array)')
        end
      end

      context 'Hash' do
        it 'should report the core class in the message' do
          src = <<-EOS
            class Dummy < Hash
            end
          EOS

          expect(src).to reek_of(:SubclassedFromCoreClass, message: 'inherits from a core class (Hash)')
        end
      end
    end
  end

  it 'does not inherit from a core class' do
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

    expect(src).to reek_of(:SubclassedFromCoreClass, ancestor: 'Array', message: 'inherits from a core class (Array)')
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
    expect(src).to reek_of(:SubclassedFromCoreClass, ancestor: 'Array')
  end

  it 'should report if we inherit from a core class using Class#new' do
    src = 'Dummy = Class.new(Array)'
    expect(src).to reek_of(:SubclassedFromCoreClass, ancestor: 'Array')
  end

  it 'should report if inner class inherit from a core class' do
    src = <<-EOS
      module Namespace
        class Dummy
          Dummiest = Class.new(Array)
        end
      end
    EOS
    expect(src).to reek_of(:SubclassedFromCoreClass, ancestor: 'Array')
  end

  it 'should not report on coincidental core class names in other namespaces' do
    src = <<-EOS
      module Namespace
        class Dummy
          Dummiest = Class.new(My::Array)
        end
      end
    EOS
    expect(src).to_not reek_of(:SubclassedFromCoreClass, ancestor: 'Array')
  end

  it 'should not report if inner class inherits from allowed classes' do
    src = <<-EOS
      module Namespace
        class Dummy
          Dummiest = Class.new(StandardError)
        end
      end
    EOS
    expect(src).to_not reek_of(:SubclassedFromCoreClass, ancestor: 'StandardError')
  end
end
