require 'spec_helper'
require 'reek/smells/feature_envy'
require 'reek/smells/smell_detector_shared'

describe Reek::Smells::FeatureEnvy do
  context 'with a singleton method' do
    ['self', 'local_call', '$global'].each do |receiver|
      it 'ignores the receiver' do
        src = "def #{receiver}.simple(arga) arga.to_s + arga.to_i end"
        expect(src).not_to reek_of(:FeatureEnvy)
      end
    end
  end

  context 'with no calls' do
    it 'does not report empty method' do
      expect('def simple(arga) end').not_to reek_of(:FeatureEnvy)
    end

    it 'does not report literal' do
      expect('def simple() 3; end').not_to reek_of(:FeatureEnvy)
    end

    it 'does not report instance variable reference' do
      expect('def simple() @yellow end').not_to reek_of(:FeatureEnvy)
    end

    it 'does not report vcall' do
      expect('def simple() y end').not_to reek_of(:FeatureEnvy)
    end

    it 'does not report references to self' do
      expect('def into; self; end').not_to reek_of(:FeatureEnvy)
    end

    it 'recognises an ivar reference within a block' do
      expect('def clean(text) text.each { @fred = 3} end').not_to reek_of(:FeatureEnvy)
    end

    it 'copes with nil superclass' do
      expect('class Object; def is_maybe?() false end end').not_to reek_of(:FeatureEnvy)
    end
  end

  context 'with only one call' do
    it 'reports a call to a parameter' do
      expect('def simple(arga) arga.to_s end').to reek_of(:FeatureEnvy, name: 'arga')
    end

    it 'reports a call to a constant' do
      expect('def simple(arga) FIELDS[arga] end').to reek_of(:FeatureEnvy)
    end
  end

  context 'with two or more calls' do
    it 'reports two calls' do
      src = 'def simple(arga) arga.to_s + arga.to_i end'
      expect(src).to reek_of(:FeatureEnvy)
    end

    it 'counts a local call in a param initializer' do
      expect('def simple(arga=local) arga.to_s end').not_to reek_of(:FeatureEnvy)
    end

    it 'should count usages of self'do
      expect('def <=>(other) Options[:sort_order].compare(self, other) end').
        not_to reek_of(:FeatureEnvy)
    end

    it 'should count self reference within a dstr' do
      expect('def as(alias_name); "#{self} as #{alias_name}".to_sym; end').
        not_to reek_of(:FeatureEnvy)
    end

    it 'should count calls to self within a dstr' do
      expect('def to_sql; "\'#{self.gsub(/\'/, "\'\'")}\'"; end').
        not_to reek_of(:FeatureEnvy)
    end

    it 'should report message chain' do
      expect('def simple(arga) arga.b.c end').to reek_of(:FeatureEnvy)
    end

    it 'does not report a method that calls super' do
      expect('def child(arg) super; arg.to_s; end').not_to reek_of(:FeatureEnvy)
    end

    it 'should recognise a deep call' do
      src = <<-EOS
        class Red
          def deep(text)
            text.each { |mod| atts = shelve(mod) }
          end

          def shelve(val)
            @shelf << val
          end
        end
      EOS
      expect(src).not_to reek_of(:FeatureEnvy)
    end
  end
end
