class Video < ApplicationRecord
  enum state: { created: 0, transcribing: 1, hacks: 2, queries: 3, scraping: 4,
                processed: 5, unprocessable: 6 }

  belongs_to :channel
  has_one_attached :cover
  has_one :transcription
  has_many :hacks
  has_many :queries, through: :hacks
  has_one :process_video_log

  after_create :create_process_log

  default_scope { order(external_created_at: :desc) }

  private

  def create_process_log
    ProcessVideoLog.create(video_id: id)
  end
end
