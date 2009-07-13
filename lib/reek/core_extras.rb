require 'reek/source'         # SMELL: should refer to Sniffer
require 'reek/sniffer'

class File
  #
  # Creates a new +Sniffer+ that assumes this File contains Ruby source
  # code and examines that code for smells.
  #
  def sniff
    result = Reek::Sniffer.new
    Reek::Source.from_path(self.path, result)
    result
  end
end

class IO
  #
  # Creates a new +Sniffer+ that assumes this IO stream contains Ruby source
  # code and examines that code for smells.
  #
  def sniff(description = 'io')
    code = self.readlines.join
    result = Reek::Sniffer.new
    Reek::Source.new(code, description, result)
    result
  end
end

class String
  #
  # Creates a new +Sniffer+ that assumes this String contains Ruby source
  # code and examines that code for smells.
  #
  def sniff
    result = Reek::Sniffer.new
    Reek::Source.new(self, 'string', result)
    result
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
