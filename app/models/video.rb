class Video < ApplicationRecord
  enum state: { downloaded: 0, processing: 1, processed: 2 }

  belongs_to :channel
  has_one_attached :cover
  has_one :transcription
  has_many :hacks
  has_many :queries, through: :hacks
end
