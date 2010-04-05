# :reek:Duplication: { allow_calls: [ puts ] }
class Dirty
  def a
    puts @s.title
    @s = fred.map {|x| x.each {|key| key += 3}}
    puts @s.title
  end

  # :reek:Duplication: { max_calls: 2 }
  def b
    puts @s.title
    @s = fred.map {|x| x.each {|key| key += 3}}
    puts @s.title
  end
end
