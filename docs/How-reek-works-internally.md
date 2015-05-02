# How reek works internally

**Using reek via bin/reek:**

```
            [bin/reek]
                |
                |
                |
          Application (cli/application.rb) +
          Options (cli/options)
                |
                |
                |
      ReekCommand (cli/reek_command)
      with Reporter (cli/report/report)
          /     |    \
         /      |     \
        /       |      \
    Source   Source   Source (source/source_code)
    |           |          |
    |           |          |
    |           |          |
 Examiner   Examiner  Examiner (examiner)
                |
                |
                |
    Examiner sets up a:
      - SourceRepository (source/source_repository)
      - a WarningCollector (core/warning_collector)

    The Examiner then goes through each source:
      - Initializing a SmellRepository (core/smell_repository)
      - getting the AST from the source
      - applying a TreeWalker(core/tree_walker) to process this syntax tree given the SmellRepository
      - finally have that SmellRepository reporting back on the WarningCollector mentioned above
                |
                |
                |
    In the last step, the reporter from the ReekCommand:
      - gathers all the warnings from the collectors of all Examiners (as you can see here https://github.com/troessner/reek/blob/master/lib/reek/cli/report/report.rb#L30)
      - outputs them with whatever output format we have chose via the cli options
```

