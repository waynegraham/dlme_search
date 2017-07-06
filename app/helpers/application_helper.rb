module ApplicationHelper
  def paragraph_separator(args)
    safe_join(args[:value].map { |paragraph| content_tag(:p, paragraph) })
  end

  def linebreak_separator(args)
    safe_join(args[:value], tag(:br))
  end

  def linkify(args)
    safe_join(args[:value].map { |v| link_to(v, v) }, tag(:br))
  end
end
