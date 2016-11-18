def init
  super
  return unless show_api_marker_section?
  if sections.first
    sections.first.place(:api_marker).before(:private)
  else
    sections :index, [:api_marker]
  end
end

def api_marker
  return if object.type == :root
  erb(:private) unless ['public', 'private'].include? api_text
end

private

def api_text
  api_text = object.has_tag?(:api) && object.tag(:api).text
  api_text = 'public' if object.has_tag?(:public)
  api_text
end

def show_api_marker_section?
  return false if object.type == :root
  case api_text
  when 'public'
    false
  when 'private'
    false
  else
    true
  end
end
