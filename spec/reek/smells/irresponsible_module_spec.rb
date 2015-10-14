require_relative '../../spec_helper'
require_lib 'reek/context/code_context'
require_lib 'reek/smells/irresponsible_module'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::IrresponsibleModule do
  it 'reports a class without a comment' do
    src = 'class BadClass; end'
    expect(src).to reek_of :IrresponsibleModule, name: 'BadClass'
  end

  it 'reports a module without a comment' do
    src = 'module BadClass; end'
    expect(src).to reek_of :IrresponsibleModule, name: 'BadClass'
  end

  it 'does not report re-opened modules' do
    src = <<-EOS
      # Abstract base class
      class C; end

      class C; def foo; end; end
    EOS
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  it 'does not report a class having a comment' do
    src = <<-EOS
      # test class
      class Responsible; end
    EOS
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  it 'reports a class with an empty comment' do
    src = <<-EOS
      #
      #
      #
      class BadClass; end
    EOS
    expect(src).to reek_of :IrresponsibleModule
  end

  it 'reports a class with a preceding comment with intermittent material' do
    src = <<-EOS
      # This is a valid comment

      require 'foo'

      class Bar; end
    EOS
    expect(src).to reek_of(:IrresponsibleModule)
  end

  it 'reports a class with a trailing comment' do
    src = <<-EOS
      class BadClass
      end # end BadClass
    EOS
    expect(src).to reek_of(:IrresponsibleModule)
  end

  it 'reports a fully qualified class name correctly' do
    src = 'class Foo::Bar; end'
    expect(src).to reek_of :IrresponsibleModule, name: 'Foo::Bar'
  end

  it 'does not report modules used only as namespaces' do
    src = <<-EOS
      module Foo
        # Describes Bar
        class Bar
          def baz
          end
        end
      end
    EOS
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  it 'does not report classes used only as namespaces' do
    src = <<-EOS
      class Foo
        # Describes Bar
        module Bar
          def qux
          end
        end
      end
    EOS
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  it 'reports modules that have both nested modules and methods' do
    src = <<-EOS
      module Foo
        def foofoo
        end
        # Describes Bar
        module Bar
        end
      end
    EOS
    expect(src).to reek_of(:IrresponsibleModule)
  end

  it 'reports modules that have both nested modules and singleton methods' do
    src = <<-EOS
      module Foo
        def self.foofoo
        end
        # Describes Bar
        module Bar
        end
      end
    EOS
    expect(src).to reek_of(:IrresponsibleModule)
  end

  it 'reports modules that have both nested modules and methods on the singleton class' do
    src = <<-EOS
      module Foo
        class << self
          def foofoo
          end
        end
        # Describes Bar
        module Bar
        end
      end
    EOS
    expect(src).to reek_of(:IrresponsibleModule)
  end

  it 'does not report namespace modules that have a nested class through assignment' do
    src = <<-EOS
      module Qux
        # Foo is responsible
        Foo = Class.new Bar do
          def quux; end
        end
      end
    EOS
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  it 'reports classes that have a defined superclass' do
    src = <<-EOS
      class Foo < Bar; end
    EOS
    expect(src).to reek_of(:IrresponsibleModule)
  end

  it 'reports classes defined through assignment' do
    src = <<-EOS
      # Qux is responsible, but Foo is not
      module Qux
        Foo = Class.new Bar
      end
    EOS
    expect(src).to reek_of(:IrresponsibleModule, name: 'Foo')
  end

  it 'reports structs defined through assignment' do
    src = <<-EOS
      # Qux is responsible, but Foo is not
      module Qux
        Foo = Struct.new(:x, :y)
      end
    EOS
    expect(src).to reek_of(:IrresponsibleModule, name: 'Foo')
  end

  it 'does not report constants that are not classes' do
    src = <<-EOS
      module Qux
        Foo = 23
        Bar = Hash.new
        Quuz = 'foo'.freeze
      end
    EOS
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  context 'when a smell is reported' do
    let(:detector) { build(:smell_detector, smell_type: :IrresponsibleModule) }

    it_should_behave_like 'SmellDetector'
  end
end
