require 'open-uri'

class ChannelsController < ApplicationController
  before_action :load_channel, only: [:process_videos]
  before_action :check_already_processing, only: [:process_videos]
  def index
    @channel = Channel.new
    @q = current_user.channels.ransack(params[:q])
    @pagy, @channels = pagy(@q.result.order(created_at: :desc), items: 25)
  end

  def create
    result = Services::Apify.new.channel_info(channel_params[:name])
    if result
      avatar = result.delete(:avatar)
      channel = current_user.channels.build(result)
      channel.avatar.attach(io:  URI.open(avatar), filename: File.basename(avatar))
      redirect_to channels_path, notice: "Channel created correctly" and return if channel.save
    end
    redirect_to channels_path, alert: "Channel cannot be created"
  end

  def process_videos
    result = Services::Apify.new.download_videos(@channel)
    redirect_to channels_path, notice: "Channel is being processed."
  end

  private

  def channel_params
    params.require(:channel).permit(:id, :name)
  end

  def load_channel
    @channel = current_user.channels.find(params[:id])
    unless @channel
      redirect_to channels_path, alert: "Channel doesn't exists"
    end
  end

  def check_already_processing
    if @channel.state.to_sym == :checking
      redirect_to channels_path, alert: "Channel already being processed."
    end
  end
end