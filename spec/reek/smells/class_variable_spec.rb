require_relative '../../spec_helper'
require_lib 'reek/smells/class_variable'

RSpec.describe Reek::Smells::ClassVariable do
  it 'reports the right values' do
    src = <<-EOS
      class Alpha
        @@bravo = 5
      end
    EOS

    expect(src).to reek_of(:ClassVariable,
                           lines:   [2],
                           context: 'Alpha',
                           message: 'declares the class variable @@bravo',
                           source:  'string',
                           name:    '@@bravo')
  end

  it 'does count all class variables' do
    src = <<-EOS
      class Alpha
        @@bravo = 42
        @@charlie = 99
      end
    EOS

    expect(src).to reek_of(:ClassVariable, name: '@@bravo')
    expect(src).to reek_of(:ClassVariable, name: '@@charlie')
  end

  it 'does not report class instance variables' do
    src = <<-EOS
      class Alpha
        @klass_instancy = 42
      end
    EOS

    expect(src).to_not reek_of(:ClassVariable)
  end

  context 'with no class variables' do
    it 'records nothing in the class' do
      src = <<-EOS
        class Alpha
          def meth; end
        end
      EOS

      expect(src).to_not reek_of(:ClassVariable)
    end

    it 'records nothing in the module' do
      src = <<-EOS
        module Alpha
          def meth; end
        end
      EOS

      expect(src).to_not reek_of(:ClassVariable)
    end
  end

  ['class', 'module'].each do |scope|
    context "Scoped to #{scope}" do
      context 'set in a method' do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} Alpha
              def meth
                @@bravo = {}
              end
            end
          EOS

          expect(src).to reek_of(:ClassVariable, name: '@@bravo')
        end
      end

      context 'used in a method' do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} Alpha
              def meth
                puts @@bravo
              end
            end
          EOS

          expect(src).to reek_of(:ClassVariable, name: '@@bravo')
        end
      end

      context "set in #{scope} and used in a method" do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} Alpha
              @@bravo = 42

              def meth
                puts @@bravo
              end
            end
          EOS

          expect(src).to reek_of(:ClassVariable, name: '@@bravo')
        end
      end
    end
  end
end
