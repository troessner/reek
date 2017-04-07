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

        def execute
          smells = scan_for_smells
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

        def scan_for_smells
          sources.map do |source|
            Examiner.new(source,
                         filter_by_smells: smell_names)
          end.map(&:smells).flatten
        end

        def groups_for(smells)
          @groups ||=
            begin
              todos = smells.group_by(&:smell_class).map do |smell_class, smells_for_class|
                smell_class.todo_configuration_for(smells_for_class)
              end
              todos.inject(&:merge)
            end
        end
      end
    end
  end
end
