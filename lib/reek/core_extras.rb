require 'reek/source'
require 'reek/sniffer'

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

class File
  #
  # Creates a new +Source+ that assumes this File contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  def to_reek_source
    Reek::SourceFile.new(self)
  end
end

class IO
  #
  # Creates a new +Source+ that assumes this IO stream contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  def to_reek_source(description = 'io')
    Reek::Source.new(self.readlines.join, description)
  end
end

class String
  #
  # Creates a new +Source+ that assumes this string contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  def to_reek_source
    Reek::Source.new(self, 'string')
  end
end

class Array
  #
  # Creates a new +Sniffer+ that assumes this Array contains the names
  # of Ruby source files and examines those files for smells.
  #
  def sniff
    sniffers = self.map {|path| File.new(path).sniff }
    Reek::SnifferSet.new(sniffers, 'dir')
  end
end
