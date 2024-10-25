class Category < ApplicationRecord
  belongs_to :clasification
  has_many :hack_category_rels
  has_many :hacks, through: :hack_category_rels
end
