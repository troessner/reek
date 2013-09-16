# :reek:DuplicateMethodCall: { allow_calls: [ puts ] }
# smells of :reek:NestedIterators but ignores them
class Dirty
  def a
    puts @s.title
    @s = fred.map {|x| x.each {|key| key += 3}}
    puts @s.title
  end

  # :reek:DuplicateMethodCall: { max_calls: 2 }
  def b
    puts @s.title
    @s = fred.map {|x| x.each {|key| key += 3}}
    puts @s.title
  end
end
