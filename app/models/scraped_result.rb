class ScrapedResult < ApplicationRecord
  belongs_to :query
  belongs_to :validation_source
end
