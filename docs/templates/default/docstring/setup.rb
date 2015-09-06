def init
  super
  if sections.first
    sections.first.place(:api_marker).before(:private)
  else
    sections :index, [:api_marker]
  end
end

def api_marker
  api_text = object.has_tag?(:api) && object.tag(:api).text
  case api_text
  when 'public'
    erb(:public_api_marker)
  when 'private'
    # Let section 'private' handle this.
  else
    erb(:private)
  end
end
