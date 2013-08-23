#
# Extensions to +Hash+ needed by Reek.
#
class Hash
  def push_keys(hash)
    keys.each {|key| hash[key].adopt!(self[key]) }
  end

  def adopt!(other)
    other.keys.each do |key|
      ov = other[key]
      if Array === ov and has_key?(key)
        self[key] += ov
      else
        self[key] = ov
      end
    end
    self
  end

  def adopt(other)
    self.deep_copy.adopt!(other)
  end

  def deep_copy
    YAML::load(YAML::dump(self))
  end
end

