# How Reek works internally


## The big picture

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
                                * uses a reporter (report/report)                                    |
                                * uses a SourceLocator (source/source_locator)                       |
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
                                  * adorns the generated AST via a TreeDresser (core/tree_dresser)
                                  * initializes a DetectorRepository with all relevant smells (smells/detector_repository)
                                  * builds a tree of Contexts using ContextBuilder
                                  * tells the DetectorRepository above to run each of its smell detectors above on each of the contexts
                                  /       |       \
                                 /        |        \
                                /         |         \
                    UtilityFunction   FeatureEnvy   TooManyMethods
                                \         |         /
                                 \        |        /
                                  \       |       /
                                   DetectorRepository
                                          |
                                          |
                                          |
                                    Application output

## A closer look at how an Examiner works

The core foundation of Reek and its API is the Examiner.
As you can see above, the Examiner is run for every source it gets passed and then runs the configured SmellDetectors.
The overall workflow is like this:

        Examiner
            |
            |
            |
        Initialize DetectorRepository only with eligible SmellDetectors
            |
            |
            |
    Generate the AST out of the given source using SourceCode#syntax_tree, which works like this:

      - We generate a "rough" AST using the "parser" gem
      - We then obtain the comments from the source code separately
      - We pass this unprocessed AST and the comment_map to TreeDresser#dress which
        returns an instance of Reek::AST::SexpNode with type-dependent SexpExtensions mixed in.

    An example should make this more palpable.
    Given:

      class C
        def m
          puts 'nada'
        end
      end

    The AST generated by the parser gem (consisting of Parser::AST::Node) looks like this:

       (class
         (const nil :C)
          nil
         (def :m
           (args)
           (send nil :puts
             (str "nada"))))

    TreeDresser#dress would transform this into a very similar tree, but this time not consisting
    of Parser::AST::Node but of Reek::AST::SexpNode and with node-dependent SexpExtensions
    mixed in (noted in []):

       (class                 [AST::SexpExtensions::ClassNode, AST::SexpExtensions::ModuleNode]
         (const nil :C)       [AST::SexpExtensions::ConstNode]
          nil
         (def :m              [AST::SexpExtensions::DefNode, AST::SexpExtensions::MethodNodeBase]
           (args)             [AST::SexpExtensions::ArgsNode]
           (send nil :puts    [AST::SexpExtensions::SendNode]
             (str "nada"))))
            |
            |
            |
      A ContextBuilder then traverses this now adorned tree again and
      runs all SmellDetectors from the DetectorRepository above
