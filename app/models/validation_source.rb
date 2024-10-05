class ValidationSource < ApplicationRecord
  has_many :scraped_results
  def build_search_url(query)
    "#{url_query}#{URI.encode_www_form_component(query.content)}"
  end
end
