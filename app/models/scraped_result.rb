class ScrapedResult < ApplicationRecord
  belongs_to :query
  belongs_to :validation_source

  scope :processed, -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false) }
  scope :unsent_to_pinecone, -> { where(sent_to_pinecone: false) }
end
