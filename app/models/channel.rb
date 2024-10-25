class Channel < ApplicationRecord
  enum state: { unchecked: 0, checking: 1, processing: 2, processed: 3, check_failed: 4 }

  belongs_to :user
  has_many :videos
  has_many :hacks, through: :videos
  has_many :apify_runs
  has_one_attached :avatar
  has_many :channel_processes

  def broadcast_state(state)
    update_attribute(:state, state)
    channel_process = channel.channel_processes.where(finished: false).last
    remaining_jobs = channel_process.count_videos if channel_process
    remaining_jobs ||= 0
    ActionCable.server.broadcast 'channel_state_channel', { id: id, state: state, remaining_jobs: remaining_jobs }
  end
end
