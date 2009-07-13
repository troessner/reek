require 'reek/source'         # SMELL: should refer to Sniffer
require 'reek/sniffer'

class File
  #
  # Creates a new +Sniffer+ that assumes this File contains Ruby source
  # code and examines that code for smells.
  #
  def sniff
    Reek::Source.from_path(self.path).sniffer
  end
end

class String
  #
  # Creates a new +Sniffer+ that assumes this String contains Ruby source
  # code and examines that code for smells.
  #
  def sniff
    result = Sniffer.new
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
    sniffers = self.map {|path| Reek::Source.from_path(path).sniffer }
    Reek::SnifferSet.new(sniffers, 'dir')
  end
end
