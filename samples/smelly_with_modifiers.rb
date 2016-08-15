# Smelly class for testing purposes
#
# Not necessary for the feature per se but for
# removing distracting output. :reek:UnusedPrivateMethod
#
class Klass
  def public_method(arg) arg.to_s; end
  protected
  def protected_method(arg) arg.to_s; end
  private
  def private_method(arg) arg.to_s; end
end
