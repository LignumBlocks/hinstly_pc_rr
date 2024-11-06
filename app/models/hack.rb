class Hack < ApplicationRecord
  belongs_to :video
  has_many :queries
  has_many :scraped_results, through: :queries
  has_one :hack_validation
  has_one :hack_structured_info, dependent: :destroy
  scope :valid_hacks, -> { where(is_hack: true) }
  has_many :hack_category_rels
  has_many :categories, through: :hack_category_rels
  has_many :clasifications, through: :categories

  def self.total_count
    count
  end
  
  def self.valid_count
    joins(:hack_validation).where(hack_validations: { status: true }).count
  end
  
  def self.not_valid_count
    left_joins(:hack_structured_info, :hack_validation)
      .where('hack_structured_infos.id IS NULL OR hack_validations.status = false OR hack_validations.status IS NULL')
      .count
  end
end
