class Hack < ApplicationRecord
  belongs_to :video
  has_many :queries
  has_many :scraped_results, through: :queries

  scope :valid_hacks, -> { where(is_hack: true) }
end
