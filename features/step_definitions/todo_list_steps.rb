Given(/^a directory 'lib' with one clean file 'clean\.rb' and one dirty file 'dirty\.rb'$/) do
  write_file('lib/clean.rb', <<-EOS.strip_heredoc)
    # clean class for testing purposes
    class Clean
      def super_clean
        puts @janitor.name
      end
    end
  EOS

  write_file('lib/dirty.rb', <<-EOS.strip_heredoc)
    class Dirty
      def a; end
      def b; end
    end
  EOS
end

Given(/^a configuration file 'config\.reek' that partially masks 'dirty\.rb'$/) do
  write_file('config.reek', <<-EOS.strip_heredoc)
    ---
    IrresponsibleModule:
      exclude:
      - Dirty
    UncommunicativeMethodName:
      exclude:
      - Dirty#b
  EOS
end

Given(/^a directory 'superclean' with one clean file 'clean\.rb'$/) do
  write_file('superclean/clean.rb', <<-EOS.strip_heredoc)
    # clean class for testing purposes
    class Clean
      def super_clean
        puts @janitor.name
      end
    end
  EOS
end
