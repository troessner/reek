require 'spec_helper'
require 'reek/spec'

include Reek
include Reek::Spec

describe ShouldReek do
  let(:matcher) { ShouldReek.new }

  describe 'checking code in a string' do
    let(:clean_code) { 'def good() true; end' }
    let(:smelly_code) { 'def x() y = 4; end' }

    it 'matches a smelly String' do
      matcher.matches?(smelly_code).should be_true
    end

    it 'doesnt match a fragrant String' do
      matcher.matches?(clean_code).should be_false
    end

    it 'reports the smells when should_not fails' do
      matcher.matches?(smelly_code)
      matcher.failure_message_for_should_not.should match('UncommunicativeVariableName')
    end
  end

  describe 'checking code in a Dir' do
    let(:clean_dir) { Dir['spec/samples/three_clean_files/*.rb'] }
    let(:smelly_dir) { Dir['spec/samples/two_smelly_files/*.rb'] }
    let(:masked_dir) { Dir['spec/samples/clean_due_to_masking/*.rb'] }

    it 'matches a smelly Dir' do
      matcher.matches?(smelly_dir).should be_true
    end

    it 'doesnt match a fragrant Dir' do
      matcher.matches?(clean_dir).should be_false
    end

    it 'masks smells using the relevant configuration' do
      matcher.matches?(masked_dir).should be_false
    end

    it 'reports the smells when should_not fails' do
      matcher.matches?(smelly_dir)
      matcher.failure_message_for_should_not.should match('UncommunicativeVariableName')
    end
  end

  describe 'checking code in a File' do
    let(:clean_file) { File.new('spec/samples/three_clean_files/clean_one.rb') }
    let(:smelly_file) { File.new('spec/samples/two_smelly_files/dirty_one.rb') }
    let(:masked_file) { File.new('spec/samples/clean_due_to_masking/dirty_one.rb') }

    it 'matches a smelly File' do
      matcher.matches?(smelly_file).should be_true
    end

    it 'doesnt match a fragrant File' do
      matcher.matches?(clean_file).should be_false
    end

    it 'masks smells using the relevant configuration' do
      matcher.matches?(masked_file).should be_false
    end

    it 'reports the smells when should_not fails' do
      matcher.matches?(smelly_file)
      matcher.failure_message_for_should_not.should match('UncommunicativeVariableName')
    end
  end
end
