class Channel < ApplicationRecord
  enum state: { unchecked: 0, checking: 1, processing: 2, processed: 3, check_failed: 4 }

  belongs_to :user
  has_many :videos
  has_many :hacks, through: :videos
  has_many :apify_runs
  has_one_attached :avatar
  has_many :channel_processes
end
