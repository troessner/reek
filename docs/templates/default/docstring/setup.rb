def init
  super
  if object.has_tag?(:api)
    sections.first.place(:public_api_marker).before(:private)
  end
end
