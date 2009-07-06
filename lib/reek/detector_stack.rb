
module Reek
  class DetectorStack

    def initialize(default_detector)
      @detectors = [default_detector]
    end

    def push(config)
      det = @detectors[0].copy
      det.configure_with(config)
      @detectors.each {|smell| smell.be_masked}
      @detectors << det
    end

    def listen_to(hooks)
      @detectors.each { |smell| smell.listen_to(hooks) }
    end

    def report_on(report)
      @detectors.each { |smell| smell.report_on(report) }
    end
  end
end
