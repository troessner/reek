Given(/^the smelly file 'demo.rb' from the example in the README$/) do
  contents = <<-EOS.strip_heredoc
    class Dirty
      # This method smells of :reek:NestedIterators but ignores them
      def awful(x, y, offset = 0, log = false)
        puts @screen.title
        @screen = widgets.map {|w| w.each {|key| key += 3 * x}}
        puts @screen.contents
      end
    end
  EOS
  write_file('demo.rb', contents)
end

Given(/^a smelly file with inline masking called 'inline.rb'$/) do
  write_file 'inline.rb', <<-EOS.strip_heredoc
    # smells of :reek:NestedIterators but ignores them
    class Dirty
      def a
        puts @s.title
        @s = foo.map {|x| x.each {|key| key += 3}}
        puts @s.title
      end
    end
  EOS
end

Given(/^the "(.*?)" sample file exists$/) do |file_name|
  full_path = File.expand_path file_name, 'spec/samples'
  in_current_dir { FileUtils.cp full_path, file_name }
end

Given(/^a directory called 'clean_files' containing some clean files$/) do
  contents = <<-EOS.strip_heredoc
    # clean class for testing purposes
    class Clean
      def assign
        puts @sub.title
        @sub.map {|para| para.name }
      end
    end
  EOS
  write_file 'clean_files/clean_one.rb', contents
  write_file 'clean_files/clean_two.rb', contents
  write_file 'clean_files/clean_three.rb', contents
end

Given(/^a directory called 'smelly' containing two smelly files$/) do
  write_file('smelly/dirty_one.rb', <<-EOS.strip_heredoc)
    class Dirty
      def a; end
    end
  EOS
  write_file('smelly/dirty_two.rb', <<-EOS.strip_heredoc)
    class Dirty
      def a; end
      def b; end
    end
  EOS
end

Given(/^a smelly file called 'smelly.rb'( in a subdirectory)?$/) do |in_subdir|
  file_name = in_subdir ? 'subdir/smelly.rb' : 'smelly.rb'
  write_file file_name, <<-EOS.strip_heredoc
    # smelly class for testing purposes
    class Smelly
      def m
        puts @foo.bar
        puts @foo.bar
      end
    end
  EOS
end

Given(/^a file with smelly variable names called 'camel_case.rb'$/) do
  write_file('camel_case.rb', <<-EOS.strip_heredoc)
    # Class containing camelCase variable which would normally smell
    class CamelCase
      def initialize
        # These next two would normally smell if it weren't for overridden config values
        camelCaseVariable = []
        anotherOne = 1

        # this next one should still smell
        x1 = 0

        # this next one should not smell
        should_not_smell = true
      end
    end
  EOS
end

Given(/^an empty configuration file called 'empty.reek'$/) do
  write_file('empty.reek', '')
end

Given(/^a corrupt configuration file called 'corrupt.reek'$/) do
  write_file('corrupt.reek', 'This is not a configuration file')
end

Given(/^a masking configuration file called 'config.reek'$/) do
  write_file('config.reek', <<-EOS.strip_heredoc)
    ---
    DuplicateMethodCall:
      enabled: false
    UncommunicativeMethodName:
      enabled: false
  EOS
end

Given(/^a configuration file masking some duplication smells called 'config.reek'$/) do
  write_file('config.reek', <<-EOS.strip_heredoc)
    ---
    DuplicateMethodCall:
      allow_calls:
        - puts\\(@foo.bar\\)
  EOS
end

Given(/^a configuration file allowing camel case variables$/) do
  write_file('config.reek', <<-EOS.strip_heredoc)
    ---
    UncommunicativeVariableName:
      enabled: true
      reject:
      - !ruby/regexp /^.$/
      - !ruby/regexp /[0-9]$/
  EOS
end

When(/^I run "reek (.*?)" in the subdirectory$/) do |args|
  cd 'subdir'
  reek(args)
end

Given(/^a masking configuration file in the HOME directory$/) do
  set_env('HOME', File.expand_path(File.join(current_dir, 'home')))
  write_file('home/config.reek', <<-EOS.strip_heredoc)
    ---
    DuplicateMethodCall:
      enabled: false
    UncommunicativeMethodName:
      enabled: false
  EOS
end

Given(/^an enabling configuration file in the subdirectory$/) do
  write_file('subdir/config.reek', <<-EOS.strip_heredoc)
    ---
    IrresponsibleModule:
      enabled: true
    UncommunicativeModuleName:
      enabled: true
    UncommunicativeMethodName:
      enabled: true
  EOS
end
