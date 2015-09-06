require 'yard'

# Template helper to modify processing of links in HTML generated from our
# markdown files.
module LocalLinkHelper
  # Rewrites links to (assumed local) markdown files so they're processed as
  # {file: } directives.
  def resolve_links(text)
    text = text.gsub(%r{<a href="([^"]*.md)">([^<]*)</a>}, '{file:\1 \2}')
    super text
  end
end

YARD::Templates::Template.extra_includes << LocalLinkHelper
YARD::Tags::Library.define_tag('Guaranteed public API', :public)
YARD::Templates::Engine.register_template_path File.join(File.dirname(__FILE__), 'templates')
