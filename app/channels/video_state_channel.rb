class VideoStateChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'video_state_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
