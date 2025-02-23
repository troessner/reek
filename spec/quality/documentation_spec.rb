# frozen_string_literal: true

require_relative '../spec_helper'
require 'kramdown'

RSpec.describe 'Documentation' do
  root = File.expand_path('../..', __dir__)
  files = Dir.glob(File.join(root, '*.md')) + Dir.glob(File.join(root, 'docs', '*.md'))
  code_types = [:codeblock, :codespan]

  files.each do |file|
    describe "from #{file}" do
      text = File.read(file)
      doc = Kramdown::Document.new(text, input: 'GFM')
      blocks = doc.root.children

      blocks.each do |block|
        # Only consider code blocks with language 'ruby'.
        next unless code_types.include?(block.type)
        next unless block.attr['class'] == 'language-ruby'

        it "has a valid sample at #{block.options[:location] + 1}" do
          code = block.value.strip
          next unless code.include?('# =>')

          # Replace lines of the form `<expression> # => <result>` with
          # assertions.
          #
          # For example,
          #
          #   2 + 2 # => 4
          #
          # will be replaced by
          #
          #   assert_equal(4, 2 + 2)
          #
          spec_code = code.gsub(/(^.+) # ?=> (.+$)/, 'assert_equal(\2, \1)')

          expect do
            eval spec_code # rubocop:disable Security/Eval
          end.not_to raise_error
        end
      end
    end
  end
end
