# frozen_string_literal: true

require_relative 'base_report'

module Reek
  module Report
    #
    # Saves the report as a HTML file
    #
    # @public
    #
    class HTMLReport < BaseReport
      require 'erb'

      # @public
      def show
        template_path = Pathname.new("#{__dir__}/html_report/html_report.html.erb")
        puts ERB.new(template_path.read).result(binding)
      end
    end
  end
end
