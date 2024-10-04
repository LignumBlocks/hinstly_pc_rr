class Hack < ApplicationRecord
  belongs_to :video
  has_many :queries
end
