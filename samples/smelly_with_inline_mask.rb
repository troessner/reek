# Smelly class
class Smelly
  # :reek:UncommunicativeVariableName: { enabled: false }
  def x    # This will reek of UncommunicativeMethodName
    y = 10 # This will NOT reek of UncommunicativeVariableName
  end
end
