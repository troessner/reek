# How reek works internally


```
["class C; end" | reek]            [reek lib/*.rb]                             [expect(files).not_to reek_of(:LargeClass)]
             \                            |                                                          |
              \                           |                                                          |
               \                          |                                                          |
                \             creates a   |                                                          |
                 \                        |                                                          |
                  \                       |                                                          |
                   \                      |                                                          |
                    \                     |                                                          |
                     \---------- Application (cli/application.rb) +                                  |
                                    Options (cli/options)                                            |
                                          |                                                          |
                                          |                                                          |
                                          |                                                          |
                                          |                                                          |
                              creates a   |                                                          |
                                          |                                                          |
                                          |                                                          |
                                          |                                                          |
                                          |                                                          |
                                ReekCommand (cli/reek_command)                                       |
                                * uses a reporter (cli/report/report)                                |
                                * uses a SourceLocator (source/source_locator)                       |
                                * uses a SourceRepository (source/source_repository)                 |
                                /         |         \                                                |
                               /          |          \                                               |
                              /           |           \                                              |
                        Source          Source      Source (source/source_code)                      |
                          |               |            |                                             |
                          |               |            |                                             |
                          |               |            |                                             |
                      Examiner            |         Examiner                                         |
                                          |                                                          |
                                          |                                                          |
                                      Examiner (core/examiner)  --------------------------------------
                                  * generates the AST out of the given source
                                  * initializes a SmellRepository with all relevant smells (smells/smell_repository)
                                  * initializes a WarningCollector (cli/warning_collector)
                                  * adorns the generated AST via a TreeWalker (core/treewalker)
                                  * runs all corresponding smell detectors via this Treewalker for the SmellRepository above
                                  /       |       \
                                 /        |        \
                                /         |         \
                    UtilityFunction   FeatureEnvy   TooManyMethods
                                \         |         /
                                 \        |        /
                                  \       |       /
                                   WarningCollector
                                          |
                                          |
                                          |
                                    Application output
