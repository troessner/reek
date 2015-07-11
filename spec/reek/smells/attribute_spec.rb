require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/attribute'
require_relative '../../../lib/reek/smells/smell_configuration'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::Attribute do
  let(:config) do
    {
      Reek::Smells::Attribute => { Reek::Smells::SmellConfiguration::ENABLED_KEY => true }
    }
  end
  let(:configuration) { test_configuration_for(config) }

  before(:each) do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :Attribute, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'with no attributes' do
    it 'records nothing' do
      expect('
        class Klass
        end
      ').to_not reek_of(:Attribute, {}, configuration)
    end
  end

  context 'with attributes' do
    it 'records nothing' do
      expect('
        class Klass
          attr :super_private, :super_private2
          private :super_private, :super_private2
          private
          attr :super_thing
          public
          attr :super_thing2
          private
          attr :super_thing2
        end
      ').to_not reek_of(:Attribute, {}, configuration)
    end

    it 'records attr attribute in a module' do
      expect('
        module Mod
          attr :my_attr
        end
      ').to reek_of(:Attribute, { name: 'my_attr' }, configuration)
    end

    it 'records attr attribute' do
      expect('
        class Klass
          attr :my_attr
        end
      ').to reek_of(:Attribute, { name: 'my_attr' }, configuration)
    end

    it 'records reader attribute' do
      expect('
        class Klass
          attr_reader :my_attr
        end
      ').to reek_of(:Attribute, { name: 'my_attr' }, configuration)
    end

    it 'records writer attribute' do
      expect('
        class Klass
          attr_writer :my_attr
        end
      ').to reek_of(:Attribute, { name: 'my_attr' }, configuration)
    end

    it 'records accessor attribute' do
      expect('
        class Klass
          attr_accessor :my_attr
        end
      ').to reek_of(:Attribute, { name: 'my_attr' }, configuration)
    end

    it 'records attr attribute after switching visbility' do
      expect('
        class Klass
          private
          attr :my_attr
          public :my_attr
          private :my_attr
          public :my_attr
        end
      ').to reek_of(:Attribute, { name: 'my_attr' }, configuration)
    end

    it "doesn't record protected attributes" do
      src = '
        class Klass
          protected
          attr :iam_protected
        end
      '
      expect(src).to_not reek_of(:Attribute, { name: 'iam_protected' }, configuration)
    end

    it "doesn't record private attributes" do
      src = '
        class Klass
          private
          attr :iam_private
        end
      '
      expect(src).to_not reek_of(:Attribute, { name: 'iam_private' }, configuration)
    end
  end
end
