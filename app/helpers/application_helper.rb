module ApplicationHelper
  def link_to_if_external_uri(text, show_only_host: false)
    uri = URI.parse(text)

    if %w( http https ).include?(uri.scheme)
      body = show_only_host ? uri.host : text
      link_to(body, text, target: '_blank')
    else
      text
    end
  rescue URI::BadURIError, URI::InvalidURIError
    text
  end
end
