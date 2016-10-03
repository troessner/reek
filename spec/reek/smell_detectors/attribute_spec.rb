require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/attribute'

RSpec.describe Reek::SmellDetectors::Attribute do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        attr_writer :bravo
      end
    EOS

    expect(src).to reek_of(:Attribute,
                           lines: [2],
                           context: 'Alfa#bravo',
                           message: 'is a writable attribute')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alfa
        attr_writer :bravo
        attr_writer :charlie
      end
    EOS

    expect(src).
      to reek_of(:Attribute, lines: [2], context: 'Alfa#bravo').
      and reek_of(:Attribute, lines: [3], context: 'Alfa#charlie')
  end

  it 'records nothing with no attributes' do
    src = <<-EOS
      class Alfa
      end
    EOS

    expect(src).not_to reek_of(:Attribute)
  end

  context 'with attributes' do
    it 'records nothing for attribute readers' do
      src = <<-EOS
        class Alfa
          attr :bravo
          attr_reader :charlie
        end
      EOS

      expect(src).not_to reek_of(:Attribute)
    end

    it 'records writer attribute' do
      src = <<-EOS
        class Alfa
          attr_writer :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Alfa#bravo')
    end

    it 'does not record writer attribute if suppressed with a preceding code comment' do
      src = <<-EOS
        class Alfa
          # :reek:Attribute
          attr_writer :bravo
        end
      EOS

      expect(src).not_to reek_of(:Attribute)
    end

    it 'records attr_writer attribute in a module' do
      src = <<-EOS
        module Mod
          attr_writer :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute)
    end

    it 'records accessor attribute' do
      src = <<-EOS
        class Alfa
          attr_accessor :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute)
    end

    it 'records attr defining a writer' do
      src = <<-EOS
        class Alfa
          attr :bravo, true
        end
      EOS

      expect(src).to reek_of(:Attribute)
    end

    it "doesn't record protected attributes" do
      src = <<-EOS
        class Alfa
          protected
          attr_writer :alfa
          attr_accessor :bravo
          attr :charlie
          attr :delta, true
          attr_reader :echo
        end
      EOS

      expect(src).not_to reek_of(:Attribute)
    end

    it "doesn't record private attributes" do
      src = <<-EOS
        class Alfa
          private
          attr_writer :alfa
          attr_accessor :bravo
          attr :charlie
          attr :delta, true
          attr_reader :echo
        end
      EOS

      expect(src).not_to reek_of(:Attribute)
    end

    it 'records attr_writer defined in public section' do
      src = <<-EOS
        class Alfa
          private
          public
          attr_writer :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute)
    end

    it 'records attr_writer after switching visbility to public' do
      src = <<-EOS
        class Alfa
          private
          attr_writer :bravo
          public :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute)
    end

    it 'resets visibility in new contexts' do
      src = <<-EOS
        class Alfa
          private
          attr_writer :bravo
        end

        class Charlie
          attr_writer :delta
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Charlie#delta')
    end

    it 'records attr_writer defining a class attribute' do
      src = <<-EOS
        class Alfa
          class << self
            attr_writer :bravo
          end
        end
      EOS

      expect(src).to reek_of(:Attribute)
    end

    it 'does not record private class attributes' do
      src = <<-EOS
        class Alfa
          class << self
            private
            attr_writer :bravo
          end
        end
      EOS

      expect(src).not_to reek_of(:Attribute)
    end
  end
end
