require 'reek'
require 'reek/code_parser'
require 'reek/report'

module CodeChecks

  include Reek

  def check(desc, src, expected, pending_str = nil)
    it(desc) do
      pending(pending_str) unless pending_str.nil?
      rpt = Analyser.new(src).analyse
      (0...rpt.length).each do |smell|
        expected[smell].each { |patt| rpt[smell].report.should match(patt) }
      end
      rpt.length.should == expected.length
    end
  end
end
