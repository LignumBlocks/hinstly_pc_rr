class ChannelStateChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'channel_state_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
