module Reek
  module Spec
    class ShouldReek
      def matches?(actual)
        @source = actual.to_source
        @source.smelly?
      end
      def failure_message_for_should
        "Expected source to reek, but it didn't"
      end
      def failure_message_for_should_not
        "Expected no smells, but got the following:\n#{@source.report}"
      end
    end

    def reek
      ShouldReek.new
    end

    class ShouldReekOf
      def initialize(klass, patterns)
        @klass = klass
        @patterns = patterns
      end
      def matches?(actual)
        @source = actual.to_source
        @source.has_smell?(@klass, @patterns)
      end
      def failure_message_for_should
        "Expected source to reek of #{@klass}, but it didn't"
      end
      def failure_message_for_should_not
        "Expected source not to reek of #{@klass}, but got:\n#{@source.report}"
      end
    end

    def reek_of(klass, *patterns)
      ShouldReekOf.new(klass, patterns)
    end

    class ShouldReekOnlyOf
      def initialize(klass, patterns)
        @klass = klass
        @patterns = patterns
      end
      def matches?(actual)
        @source = actual.to_source
        @source.report.length == 1 and @source.has_smell?(@klass, @patterns)
      end
      def failure_message_for_should
        "Expected source to reek only of #{@klass}, but got:\n#{@source.report}"
      end
      def failure_message_for_should_not
        "Expected source not to reek only of #{@klass}, but it did"
      end
    end

    def reek_only_of(klass, *patterns)
      ShouldReekOnlyOf.new(klass, patterns)
    end
  end
end

class File
  def to_source
    Source.from_f(self)
  end
end

class String
  def to_source
    Source.from_s(self)
  end
end

module Reek
  class Source
    def to_source
      self
    end
  end
end
