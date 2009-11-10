
module Reek
  class DetectorStack

    def initialize(default_detector)
      @detectors = [default_detector]
    end

    def push(config)
      clone = @detectors[-1].supersede_with(config)
      @detectors << clone
    end

    def listen_to(hooks)
      @detectors.each { |det| det.listen_to(hooks) }
    end

    def report_on(report)
      @detectors.each { |det| det.report_on(report) }
    end

    def num_smells
      @detectors.inject(0) { |total, detector| total += detector.num_smells }
    end

    def has_smell?(patterns)
      @detectors.each { |det| return true if det.has_smell?(patterns) }
      false
    end

    def smelly?
      # SMELL: Duplication: look at all those loops!
      @detectors.each { |det| return true if det.smelly? }
      false
    end
  end
end
