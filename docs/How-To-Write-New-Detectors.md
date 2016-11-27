## How to write new detectors

### Outline what you have in mind

Before starting to code you should discuss the overall idea for your new smell detector with
us in a corresponding github issue.
We all should have a solid understanding of what this detector actually reports, the edgecases
it covers and the overall rationale behind it.

### Structure

All smell detectors reside in `lib/reek/smell_detectors` and have the following base structure:

```Ruby
require_relative 'base_detector'
require_relative 'smell_warning'

module Reek
  module SmellDetectors
    #
    # Here goes your introduction for this detector.
    #
    # See {file:docs/Your-Detector.md} for details.
    class YourDetector < BaseDetector
      def self.contexts
        [:class] # In case you're operating on class contexts only - just an example.
      end

      #
      # Here you should document what you expect "ctx" to look like.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        # "found_smells" below is just an abstraction for
        # "find the smells in question" and iteratore over them.
        # This can just be a method but it can also be a more sophisticated set up.
        # Check out other smell detectors to get a feeling for what to do here.
        found_smells(ctx).map do |smell|
          # "smell_warning" is defined in BaseDetector and should be used by you
          # to construct smell warnings
          smell_warning(
            context: ctx,
            lines: [], # lines on which the smell was detected
            message: "...", # the message that is printed on STDOUT
            # whatever you interpolate into the "message" should go into
            # parameters below - if you do not interpolate anything you
            # can omit this
            parameters: { })
          end
        end
      end

      private

      # Here goes everything you need for finding smells.
    end
  end
end
```

For your detector to be properly loaded you need to require it in `lib/reek/smell_detectors.rb` as well.

### defaults.reek

After you ran

```
bundle exec rake
```

for the first time with your shiny new detector in place the `defaults.reek`
file should have been updated automatically. Make sure you don't forget to check
in those changes as well.

### Documentation

* Above every `SmellDetector::sniff` method it should be documented what the expected AST is
* Every detector should have a separate documentation page in /docs. You can
  take any arbitrary existing smell detector documentation page as template (since
  they all have the same structure already)
* The detector should be listed under [Code Smells](docs/Code-Smells.md)
* Depending on what your detector does it might make sense to add it to other doc pages as
  well e.g. [Simulated Polymorphism](docs/Simulated-Polymorphism.md)

### Rspec examples

All smell detector specs start out with 2 generic examples like below - the second one
only if it makes sense.
Here's what it looks like for `UncommunicativeVariableName`:

```Ruby
it 'reports the right values' do
  src = <<-EOS
    def alfa
      bravo = 5
    end
  EOS

  expect(src).to reek_of(:UncommunicativeVariableName,
                         lines:   [2],
                         context: 'alfa',
                         message: "has the variable name 'bravo'",
                         source:  'string',
                         name:    'bravo')
end

it 'does count all occurences' do
  src = <<-EOS
    def alfa
      bravo = 3
      charlie = 7
    end
  EOS

  expect(src).to reek_of(:UncommunicativeVariableName,
                         lines: [2],
                         name:  'bravo')
  expect(src).to reek_of(:UncommunicativeVariableName,
                         lines: [3],
                         name:  'charlie')
end
```

The following examples should then cover the detector specific features.

### Cucumber features

We are trying to write as few Cucumber features as possible.
Normally, there should be no need to write a new feature for a new smell detector.
If you feel like this is necessary in this case, please discuss this with us via
github issue or in your work-in-progress pull request before doing anything.
