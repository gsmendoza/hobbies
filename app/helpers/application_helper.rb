module ApplicationHelper
  def link_to_if_external_uri(text)
    uri?(text) ? link_to(text, text, target: '_blank') : text
  end

  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError
    false
  rescue URI::InvalidURIError
    false
  end
end
