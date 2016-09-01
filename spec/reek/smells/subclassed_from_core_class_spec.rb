require_relative '../../spec_helper'
require_lib 'reek/smells/subclassed_from_core_class'

RSpec.describe Reek::Smells::SubclassedFromCoreClass do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy < Hash
      end
    EOS

    expect(src).to reek_of(:SubclassedFromCoreClass,
                           lines:    [1],
                           context:  'Dummy',
                           message:  'inherits from a core class (Hash)',
                           source:   'string',
                           ancestor: 'Hash')
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

  it 'does not report when not inheriting from a core class' do
    src = <<-EOS
      class Dummy
      end
    EOS

    expect(src).to_not reek_of(:SubclassedFromCoreClass)
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

    expect(src).to_not reek_of(:SubclassedFromCoreClass)
  end

  it 'should not report if inner class inherits from allowed classes' do
    src = <<-EOS
      module Namespace
        class Dummy
          Dummiest = Class.new(StandardError)
        end
      end
    EOS

    expect(src).to_not reek_of(:SubclassedFromCoreClass)
  end

  it 'should not report if class is created with Struct.new' do
    src = <<-EOS
      module Namespace
        class Dummy
          Dummiest = Struct.new('Array')
        end
      end
    EOS

    expect(src).to_not reek_of(:SubclassedFromCoreClass)
  end

  it 'should only report classes created with Class.new' do
    src = <<-EOS
      module Namespace
        class Dummy
          Dummiest = Foo.new(Array)
        end
      end
    EOS

    expect(src).to_not reek_of(:SubclassedFromCoreClass)
  end
end
