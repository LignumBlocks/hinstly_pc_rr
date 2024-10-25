class Hack < ApplicationRecord
  belongs_to :video
  has_many :queries
  has_many :scraped_results, through: :queries
  has_one :hack_validation
  has_one :hack_structured_info, dependent: :destroy
  scope :valid_hacks, -> { where(is_hack: true) }
  has_many :hack_category_rels
  has_many :categorias, through: :hack_category_rels
end
