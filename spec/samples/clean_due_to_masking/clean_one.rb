# clean class for testing purposes
class Clean
  def initialize(sub)
    @sub = sub
  end

  def assign
    puts @sub.title
    @sub.map {|para| para.name }
  end
end
