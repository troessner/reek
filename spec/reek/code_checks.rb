require 'reek/source'
require 'reek/code_parser'
require 'reek/report'

module CodeChecks

  include Reek

  def check(desc, src, expected, pending_str = nil)
    it(desc) do
      pending(pending_str) unless pending_str.nil?
      rpt = Source.new(src).analyse
      rpt.length.should == expected.length
      (0...rpt.length).each do |line|
        expected[line].each { |patt| rpt[line].report.should match(patt) }
      end
    end
  end
end
