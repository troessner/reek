# frozen_string_literal: true
require_relative 'base_command'
require_relative '../../examiner'

module Reek
  module CLI
    module Command
      #
      # A command to collect smells from a set of sources and writes a configuration
      # file that can serve as a todo list.
      #
      class TodoListCommand < BaseCommand
        FILE_NAME = '.todo.reek'.freeze

        def execute(app)
          smells = scan_for_smells(app)
          if smells.empty?
            puts "\n'.todo.reek' not generated because "\
                    'there were no smells found!'
          else
            File.write FILE_NAME, groups_for(smells).to_yaml
            puts "\n'.todo.reek' generated! You can now use "\
                    'this as a starting point for your configuration.'
          end
          options.success_exit_code
        end

        private

        def scan_for_smells(app)
          sources.map do |source|
            Examiner.new(source,
                         smell_names,
                         configuration: app.configuration)
          end.map(&:smells).flatten
        end

        def groups_for(smells)
          @groups ||= begin
            Hash[
              smells.group_by(&:smell_type).map do |smell_type, smells_for_type|
                [smell_type, { 'exclude' => smells_for_type.map(&:context) }]
              end
            ]
          end
        end
      end
    end
  end
end
