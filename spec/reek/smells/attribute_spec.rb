require_relative '../../spec_helper'
require_lib 'reek/smells/attribute'

RSpec.describe Reek::Smells::Attribute do
  it 'reports the right values' do
    src = <<-EOS
      class Alpha
        attr_writer :bravo
      end
    EOS

    expect(src).to reek_of(:Attribute,
                           lines: [2],
                           context: 'Alpha#bravo',
                           message: 'is a writable attribute')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alpha
        attr_writer :bravo
        attr_writer :charlie
      end
    EOS

    expect(src).to reek_of(:Attribute,
                           lines:   [2],
                           context: 'Alpha#bravo')
    expect(src).to reek_of(:Attribute,
                           lines:   [3],
                           context: 'Alpha#charlie')
  end

  it 'records nothing with no attributes' do
    src = <<-EOS
      class Alpha
      end
    EOS

    expect(src).to_not reek_of(:Attribute)
  end

  context 'with attributes' do
    it 'records nothing for attribute readers' do
      src = <<-EOS
        class Alpha
          attr :bravo
          attr_reader :charlie
        end
      EOS
      expect(src).to_not reek_of(:Attribute)
    end

    it 'records writer attribute' do
      src = <<-EOS
        class Alpha
          attr_writer :bravo
        end
      EOS
      expect(src).to reek_of(:Attribute, context: 'Alpha#bravo')
    end

    it 'does not record writer attribute if suppressed with a preceding code comment' do
      src = <<-EOS
        class Alpha
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

      expect(src).to reek_of(:Attribute, context: 'Mod#bravo')
    end

    it 'records accessor attribute' do
      src = <<-EOS
        class Alpha
          attr_accessor :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Alpha#bravo')
    end

    it 'records attr defining a writer' do
      src = <<-EOS
        class Alpha
          attr :bravo, true
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Alpha#bravo')
    end

    it "doesn't record protected attributes" do
      src = <<-EOS
        class Alpha
          protected
          attr_writer :alpha
          attr_accessor :bravo
          attr :charlie
          attr :delta, true
          attr_reader :echo
        end
      EOS

      expect(src).to_not reek_of(:Attribute)
    end

    it "doesn't record private attributes" do
      src = <<-EOS
        class Alpha
          private
          attr_writer :alpha
          attr_accessor :bravo
          attr :charlie
          attr :delta, true
          attr_reader :echo
        end
      EOS

      expect(src).to_not reek_of(:Attribute)
    end

    it 'records attr_writer defined in public section' do
      src = <<-EOS
        class Alpha
          private
          public
          attr_writer :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Alpha#bravo')
    end

    it 'records attr_writer after switching visbility to public' do
      src = <<-EOS
        class Alpha
          private
          attr_writer :bravo
          public :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Alpha#bravo')
    end

    it 'resets visibility in new contexts' do
      src = <<-EOS
        class Alpha
          private
          attr_writer :bravo
        end

        class OtherAlpha
          attr_writer :bravo
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'OtherAlpha#bravo')
    end

    it 'records attr_writer defining a class attribute' do
      src = <<-EOS
        class Alpha
          class << self
            attr_writer :bravo
          end
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Alpha#bravo')
    end

    it 'does not record private class attributes' do
      src = <<-EOS
        class Alpha
          class << self
            private
            attr_writer :bravo
          end
        end
      EOS

      expect(src).not_to reek_of(:Attribute)
    end

    it 'tracks visibility in metaclasses separately' do
      src = <<-EOS
        class Alpha
          private
          class << self
            attr_writer :bravo
          end
        end
      EOS

      expect(src).to reek_of(:Attribute, context: 'Alpha#bravo')
    end
  end
end
