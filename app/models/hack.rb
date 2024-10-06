class Hack < ApplicationRecord
  belongs_to :video
  has_many :queries

  scope :valid_hacks, -> { where(is_hack: true) }
end
