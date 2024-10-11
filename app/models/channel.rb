class Channel < ApplicationRecord
  enum state: { unchecked: 0, checking: 1, checked: 2, check_failed: 3}

  belongs_to :user
  has_many :videos
  has_many :hacks, through: :videos
  has_many :apify_runs
  has_one_attached :avatar
end
