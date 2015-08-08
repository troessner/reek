require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/attribute'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::Attribute do
  before(:each) do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :Attribute, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'with no attributes' do
    it 'records nothing' do
      src = <<-EOS
        class Klass
        end
      EOS
      expect(src).to_not reek_of(:Attribute)
    end
  end

  context 'with attributes' do
    it 'records nothing for attribute readers' do
      src = <<-EOS
        class Klass
          attr :my_attr
          attr_reader :my_attr2
        end
      EOS
      expect(src).to_not reek_of(:Attribute)
    end

    it 'records writer attribute' do
      src = <<-EOS
        class Klass
          attr_writer :my_attr
        end
      EOS
      expect(src).to reek_of(:Attribute, name: 'my_attr')
    end

    it 'records attr_writer attribute in a module' do
      src = <<-EOS
        module Mod
          attr_writer :my_attr
        end
      EOS
      expect(src).to reek_of(:Attribute, name: 'my_attr')
    end

    it 'records accessor attribute' do
      src = <<-EOS
        class Klass
          attr_accessor :my_attr
        end
      EOS
      expect(src).to reek_of(:Attribute, name: 'my_attr')
    end

    it 'records attr defining a writer' do
      src = <<-EOS
        class Klass
          attr :my_attr, true
        end
      EOS
      expect(src).to reek_of(:Attribute, name: 'my_attr')
    end

    it "doesn't record protected attributes" do
      src = '
        class Klass
          protected
          attr_writer :attr1
          attr_accessor :attr2
          attr :attr3
          attr :attr4, true
          attr_reader :attr5
        end
      '
      expect(src).to_not reek_of(:Attribute)
    end

    it "doesn't record private attributes" do
      src = '
        class Klass
          private
          attr_writer :attr1
          attr_accessor :attr2
          attr :attr3
          attr :attr4, true
          attr_reader :attr5
        end
      '
      expect(src).to_not reek_of(:Attribute)
    end

    it 'records attr_writer defined in public section' do
      src = <<-EOS
        class Klass
          private
          public
          attr_writer :my_attr
        end
      EOS
      expect(src).to reek_of(:Attribute, name: 'my_attr')
    end

    it 'records attr_writer after switching visbility to public' do
      src = <<-EOS
        class Klass
          private
          attr_writer :my_attr
          public :my_attr
        end
      EOS
      expect(src).to reek_of(:Attribute, name: 'my_attr')
    end

    it 'resets visibility in new contexts' do
      src = '
        class Klass
          private
          attr_writer :attr1
        end

        class OtherKlass
          attr_writer :attr1
        end
      '
      expect(src).to reek_of(:Attribute)
    end
  end
end
