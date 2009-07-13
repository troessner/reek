class Clean
  def assign
    puts @sub.title
    @sub.map {|para| para.name }
  end
end
