require 'open-uri'

class ChannelsController < ApplicationController
  before_action :load_channel, only: [:process_videos]
  before_action :check_already_processing, only: [:process_videos]
  skip_before_action :verify_authenticity_token, only: [:apify_webhook]
  skip_before_action :authenticate_user!, only: [:apify_webhook]
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
      channel.avatar.attach(io:  URI.open(avatar), filename: File.basename(avatar)) if avatar
      redirect_to channels_path, notice: "Channel created correctly" and return if channel.save
    end
    redirect_to channels_path, alert: "Channel cannot be created"
  end

  def show
    @channel = current_user.channels.find(params[:id])
  end

  def process_videos
    result = Services::Apify.new.download_videos(@channel)
    if result
      redirect_to channels_path, notice: "Started channel processing."
    else
      redirect_to channels_path, alert: "Unable to process channel."
    end
  end

  def apify_webhook
    run = ApifyRun.where(state: 0, apify_run_id: params[:eventData][:actorRunId]).first
    render json: {message: "ok"}, state: 200 and return unless run

    if params[:eventType] == "ACTOR.RUN.SUCCEEDED"
      channel = run.channel
      count_videos = 0
      items = Services::Apify.new.read_dataset(run.apify_dataset_id)
      items.each do |item|
        video = create_video!(channel, item)
        if video.state.to_sym == :created
          ProcessVideoJob.perform_later(video.id)
          count_videos += 1
        end
      end
      if count_videos > 0
        channel.channel_processes.create(count_videos: count_videos)
        channel.update(state: 2)
      else
        channel.update(state: 3, checked_at: DateTime.now)
      end
      run.update(state: 1)
    end
  end

  private

  def create_video!(channel, dataset_item)
    video = channel.videos.new
    video.external_source_id = dataset_item[:id]
    video.external_created_at = Time.at(dataset_item[:createTime]).to_datetime
    video.digg_count = dataset_item[:diggCount]
    video.comment_count = dataset_item[:commentCount]
    video.share_count = dataset_item[:shareCount]
    video.play_count = dataset_item[:playCount]
    video.source_link = dataset_item[:webVideoUrl]
    video.duration = dataset_item[:videoMeta][:duration]
    video.source_download_link = dataset_item[:videoMeta][:downloadAddr]
    return nil unless video.save

    video.cover.attach(io: URI.open(dataset_item[:videoMeta][:coverUrl]), filename: File.basename(dataset_item[:videoMeta][:coverUrl]))
    video.update_attribute(:state, :unprocessable) unless video.source_download_link
    video
  end

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