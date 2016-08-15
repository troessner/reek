# Smelly class
# disables :reek:UncommunicativeVariableName
class Smelly
  # This will reek of UncommunicativeMethodName
  def x
    y = 10 # This will NOT reek of UncommunicativeVariableName
  end
end
