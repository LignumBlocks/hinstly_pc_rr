class Query < ApplicationRecord
  belongs_to :hack
  has_many :scraped_results
end
