require 'reek/adapters/source'
require 'reek/adapters/source_file'
require 'reek/sniffer'

#
# Extensions to +Object+ needed by Reek.
#
class Object
  #
  # Creates a new +Sniffer+ that assumes this object contains Ruby source
  # code and examines that code for smells. Calls +to_reek_source+ on self
  # to obtain the +Source+ object wrapper.
  #
  def sniff
    Reek::Sniffer.new(self.to_reek_source)
  end
end

#
# Extensions to +File+ needed by Reek.
#
class File
  #
  # Creates a new +Source+ that assumes this File contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  def to_reek_source
    Reek::SourceFile.new(path)
  end
end

#
# Extensions to +IO+ needed by Reek.
#
class IO
  #
  # Creates a new +Source+ that assumes this IO stream contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  def to_reek_source(description = 'io')
    Reek::Source.new(self.readlines.join, description)
  end
end

#
# Extensions to +String+ needed by Reek.
#
class String
  #
  # Creates a new +Source+ that assumes this string contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  def to_reek_source
    Reek::Source.new(self, 'string')
  end
end

#
# Extensions to +Array+ needed by Reek.
#
class Array
  def paths
    self.map do |path|
      if test 'd', path
        Dir["#{path}/**/*.rb"].paths
      else
        path
      end
    end.flatten.sort
  end

  #
  # Creates a new +Sniffer+ that assumes this Array contains the names
  # of Ruby source files and examines those files for smells.
  #
  def sniff
    sniffers = valid_paths.map {|path| File.new(path).sniff}
    Reek::SnifferSet.new(sniffers, 'dir')
  end

  def valid_paths
    paths.select do |path|
      if test 'f', path
        true
      else
        $stderr.puts "Error: No such file - #{path}"
        false
      end
    end
  end
end
