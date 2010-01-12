require File.join(File.dirname(File.expand_path(__FILE__)), 'source')
require File.join(File.dirname(File.expand_path(__FILE__)), 'source_file')
require File.join(File.dirname(File.expand_path(__FILE__)), 'source_locator')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'sniffer')

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
  #
  # Creates a new +Sniffer+ that assumes this Array contains the names
  # of Ruby source files and examines those files for smells.
  #
  def sniff
    sniffers = SourceLocator.new(self).all_sniffers
    Reek::SnifferSet.new(sniffers, 'dir')
  end
end
