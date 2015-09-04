def init
  super
  sections.last.place(:public_api_marker).before(:source)
end
