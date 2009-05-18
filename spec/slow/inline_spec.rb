require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'sample gem source code' do
  it "reports the correct smells in inline.rb" do
    ruby = File.new("#{SAMPLES_DIR}/inline.rb").to_source
    ruby.should reek_of(:ControlCouple, /Inline::C#parse_signature/, /raw/)
    ruby.should reek_of(:ControlCouple, /Module#inline/, /options/)
    ruby.should reek_of(:Duplication, /Inline::C#build/, /\(\$\?\ == 0\)/)
    ruby.should reek_of(:Duplication, /Inline::C#build/, /Inline.directory/)
    ruby.should reek_of(:Duplication, /Inline::C#build/, /io.puts/)
    ruby.should reek_of(:Duplication, /Inline::C#build/, /io.puts\("#endif"\)/)
    ruby.should reek_of(:Duplication, /Inline::C#build/, /io.puts\("#ifdef __cplusplus"\)/)
    ruby.should reek_of(:Duplication, /Inline::C#build/, /module_name/)
    ruby.should reek_of(:Duplication, /Inline::C#build/, /warn\("Output:\\n\#\{result\}"\)/)
    ruby.should reek_of(:Duplication, /Inline::C#crap_for_windoze/, /Config::CONFIG\["libdir"\]/)
    ruby.should reek_of(:Duplication, /Inline::C#generate/, /result.sub!\(\/\\A\\n\/, ""\)/)
    ruby.should reek_of(:Duplication, /Inline::C#generate/, /signature\["args"\]/)
    ruby.should reek_of(:Duplication, /Inline::C#generate/, /signature\["args"\].map/)
    ruby.should reek_of(:Duplication, /Inline::C#initialize/, /stack.empty?/)
    ruby.should reek_of(:Duplication, /Inline::C#load/, /so_name/)
    ruby.should reek_of(:Duplication, /Inline::self.rootdir/, /env.nil?/)
    ruby.should reek_of(:Duplication, /Module#inline/, /Inline.const_get\(lang\)/)
    ruby.should reek_of(:FeatureEnvy, /Inline::C#strip_comments/, /src/)
    ruby.should reek_of(:LargeClass, /Inline::C/, /instance variables/)
    ruby.should reek_of(:LongMethod, /File#self.write_with_backup/)
    ruby.should reek_of(:LongMethod, /Inline::C#build/)
    ruby.should reek_of(:LongMethod, /Inline::C#generate/)
    ruby.should reek_of(:LongMethod, /Inline::C#load_cache/)
    ruby.should reek_of(:LongMethod, /Inline::C#module_name/)
    ruby.should reek_of(:LongMethod, /Inline::C#parse_signature/)
    ruby.should reek_of(:LongMethod, /Inline::self.rootdir/)
    ruby.should reek_of(:LongMethod, /Module#inline/)
    ruby.should reek_of(:NestedIterators, /Inline::C#build/)
    ruby.should reek_of(:UncommunicativeName, /Inline::C#build/, /'t'/)
    ruby.should reek_of(:UncommunicativeName, /Inline::C#build/, /'n'/)
    ruby.should reek_of(:UncommunicativeName, /Inline::C#c/, /'c'/)
    ruby.should reek_of(:UncommunicativeName, /Inline::C#module_name/, /'m'/)
    ruby.should reek_of(:UncommunicativeName, /Inline::C#module_name/, /'x'/)
    ruby.should reek_of(:UncommunicativeName, /Inline::C#parse_signature/, /'x'/)
    ruby.should reek_of(:UtilityFunction, /Inline::C#strip_comments/)
    ruby.report.should have_at_most(35).smells
  end
end
