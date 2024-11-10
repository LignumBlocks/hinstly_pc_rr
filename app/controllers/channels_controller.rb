require 'open-uri'

class ChannelsController < ApplicationController
  before_action :load_channel, only: [:process_videos]
  before_action :check_already_processing, only: [:process_videos]
  skip_before_action :verify_authenticity_token, only: [:apify_webhook]
  skip_before_action :authenticate_user!, only: [:apify_webhook]
  def index
    @channel = Channel.new
    @q = current_user.channels.ransack(params[:q])

    channel_filter = params[:filter] || 'all'

    case channel_filter
    when 'processed'
      @q = processed_channels_ransack(params[:q])
    end

    @pagy, @channels = pagy(@q.result.reorder(created_at: :desc), items: 50)
  end

  def create
    result = Services::Apify.new.channel_info(channel_params[:name])
    if result
      avatar = result.delete(:avatar)
      channel = current_user.channels.build(result)
      channel.avatar.attach(io:  URI.open(avatar), filename: File.basename(avatar)) if avatar
      redirect_to channels_path, notice: 'Channel created correctly' and return if channel.save
    end
    redirect_to channels_path, alert: 'Channel cannot be created'
  end

  def show
    @channel = current_user.channels.find(params[:id])
    @q = @channel.videos.ransack(params[:q])
    @pagy, @videos = pagy(@q.result.order(created_at: :desc), items: 50)
  end

  def process_videos
    result = Services::Apify.new.download_videos(@channel)
    if result
      redirect_to channels_path, notice: 'Started channel processing.'
    else
      redirect_to channels_path, alert: 'Unable to process channel.'
    end
  end

  def process_videos_test
    load_videos_from_db(params[:id])
    redirect_to channels_path, notice: 'Started channel processing.'
  end

  def load_videos_from_db(channel_id)
    channel = Channel.find_by(id: channel_id)

    videos = Video.where(channel_id: channel.id, state: :hacks)
    count_videos = videos.size

    if count_videos.positive?
      channel.channel_processes.create(count_videos: count_videos)
      channel.broadcast_state(:processing)
      videos.each do |video|
        ProcessVideoJob.perform_later(video.id)
      end
    else
      channel.broadcast_state(:processed)
      channel.update(checked_at: DateTime.now)
    end
  end

  def apify_webhook
    run = ApifyRun.where(state: 0, apify_run_id: params[:eventData][:actorRunId]).first
    render json: { message: 'ok' }, state: 200 and return unless run

    return unless params[:eventType] == 'ACTOR.RUN.SUCCEEDED'

    channel = run.channel
    items = Services::Apify.new.read_dataset(run.apify_dataset_id)

    created_videos = items.map do |item|
      video = create_video!(channel, item)
      video if video.state.to_sym == :created
    end.compact

    if created_videos.any?
      channel.channel_processes.create(count_videos: created_videos.size)
      channel.broadcast_state(:processing)

      created_videos.each do |video|
        ProcessVideoJob.perform_later(video.id)
      end
    else
      channel.broadcast_state(:processed)
      channel.update(checked_at: DateTime.now)
    end

    run.update(state: 1)
  end

  private

  def processed_channels_ransack(query_params)
    current_user.channels.where(state: 3).ransack(query_params)
  end

  def create_video!(channel, dataset_item)
    video = channel.videos.new
    video.external_source_id = dataset_item[:id]
    video.external_created_at = Time.at(dataset_item[:createTime]).to_datetime
    video.digg_count = dataset_item[:diggCount]
    video.comment_count = dataset_item[:commentCount]
    video.share_count = dataset_item[:shareCount]
    video.play_count = dataset_item[:playCount]
    video.source_link = dataset_item[:webVideoUrl]
    video.text = dataset_item[:text]
    video.duration = dataset_item[:videoMeta][:duration]
    video.source_download_link = dataset_item[:videoMeta][:downloadAddr]
    return nil unless video.save

    video.cover.attach(io: URI.open(dataset_item[:videoMeta][:coverUrl]),
                       filename: File.basename(dataset_item[:videoMeta][:coverUrl]))
    video.update_attribute(:state, :unprocessable) unless video.source_download_link
    video
  end

  def channel_params
    params.require(:channel).permit(:id, :name)
  end

  def load_channel
    @channel = current_user.channels.find(params[:id])
    return if @channel

    redirect_to channels_path, alert: "Channel doesn't exists"
  end

  def check_already_processing
    return unless %i[checking processing].include?(@channel.state.to_sym)

    redirect_to channels_path, alert: 'Channel already being processed.'
  end
end
