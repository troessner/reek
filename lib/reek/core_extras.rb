require 'reek/source'         # SMELL: should refer to Sniffer

class File
  def sniff
    Reek::Source.from_path(self.path).sniffer
  end
end

class String
  def sniff
    Reek::Source.from_s(self).sniffer
  end
end

class Array
  def sniff
    sniffers = self.map {|path| Reek::Source.from_path(path).sniffer }
    Reek::SnifferSet.new(sniffers, 'dir')
  end
end
