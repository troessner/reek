
module Reek
  class DetectorStack

    def initialize(default_detector)
      @detectors = [default_detector]
    end

    def push(config)
      clone = @detectors[0].copy
      clone.configure_with(config)
      @detectors.each {|det| det.be_masked}
      @detectors << clone
    end

    def listen_to(hooks)
      @detectors.each { |det| det.listen_to(hooks) }
    end

    def report_on(report)
      @detectors.each { |det| det.report_on(report) }
    end

    def num_smells
      total = 0
      @detectors.each { |det| total += det.num_smells }
      total
    end

    def has_smell?(patterns)
      @detectors.each { |det| return true if det.has_smell?(patterns) }
      false
    end

    def smelly?
      @detectors.each { |det| return true if det.smelly? }
      false
    end
  end
end
