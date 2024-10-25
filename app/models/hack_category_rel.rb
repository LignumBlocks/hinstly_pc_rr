class HackCategoryRel < ApplicationRecord
  belongs_to :hack
  belongs_to :category

  validates :justification, presence: true
end
