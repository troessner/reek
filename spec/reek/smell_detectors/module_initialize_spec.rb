require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/module_initialize'

RSpec.describe Reek::SmellDetectors::ModuleInitialize do
  it 'reports the right values' do
    src = <<-RUBY
      module Alfa
        def initialize; end
      end
    RUBY

    expect(src).to reek_of(:ModuleInitialize,
                           lines:   [1],
                           context: 'Alfa',
                           message: 'has initialize method',
                           source:  'string')
  end

  it 'reports nothing for a method with a different name' do
    src = <<-RUBY
      module Alfa
        def bravo; end
      end
    RUBY

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'reports nothing for a method named initialize in a nested class' do
    src = <<-RUBY
      module Alfa
        class Bravo
          def initialize; end
        end
      end
    RUBY

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'reports nothing for a method named initialize in a nested struct' do
    src = <<-RUBY
      module Alfa
        Bravo = Struct.new(:charlie) do
          def initialize; end
        end
      end
    RUBY

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'reports nothing for a method named initialize in a nested dynamic class' do
    src = <<-RUBY
      module Alfa
        def self.bravo
          Class.new do
            def initialize; end
          end
        end
      end
    RUBY

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'can be disabled via comment' do
    src = <<-RUBY
      # :reek:ModuleInitialize
      module Alfa
        def initialize; end
      end
    RUBY

    expect(src).not_to reek_of(:ModuleInitialize)
  end
end
