require 'open-uri'

class ProcessVideoJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    video = Video.find(arguments[0])
    video.update_attribute(:state, :failed)
    broadcast_video_state(video)
    raise exception
  end

  def perform(video_id)
    video = Video.find(video_id)
    client = OpenAI::Client.new

    transcript_video(video, client) unless video.process_video_log.transcribed?
    puts 'Transcribed downloaded_video'

    if video.state.to_sym != :unprocessable
      find_hack(video) unless video.process_video_log.has_hacks?
      puts 'Hack gotten'

      if video.hack.is_hack?
        find_queries(video) unless video.process_video_log.has_queries?
        puts 'has queries'

        scrapper = Services::Scrapper.new(ValidationSource.all, video.queries)

        unless video.process_video_log.has_scraped_pages?
          video.update_attribute(:state, :scraping)
          broadcast_video_state(video)
          scrapper.prepare_links! unless video.process_video_log.has_links_to_scrap?
          video.process_video_log.update(has_links_to_scrap: true)

          scrapper.process_links!
          video.process_video_log.update(has_scraped_pages: true)
        end

        unless video.process_video_log.analysed?
          video.update_attribute(:state, :analysing)
          broadcast_video_state(video)
          hack_processor = Ai::HackProcessor.new(video.hack)
          hack_processor.validate_financial_hack! unless video.hack&.hack_validation
          hack_processor.extend_hack! if video.hack&.hack_structured_info.blank? && video.hack&.hack_validation.status == true
          hack_processor.classify_hack! if video.hack&.hack_structured_info.present?
          video.process_video_log.update(analysed: true)
        end
      end

      video.update(state: :processed, processed_at: DateTime.now)
      broadcast_video_state(video)
    end

    update_channel_state!(video)
  end

  private

  def update_channel_state!(video)
    channel = video.channel
    channel_process = channel.channel_processes.where(finished: false).last
    remaining_videos_count = channel_process.count_videos - 1
    if remaining_videos_count <= 0
      channel_process.update(finished: true, count_videos: remaining_videos_count)
      channel.broadcast_state(:processed)
      channel.update(checked_at: DateTime.now)
    else
      channel_process.update(finished: false, count_videos: remaining_videos_count)
      channel.broadcast_state(:processing)
    end
  end

  def transcript_video(video, client)
    attempts = 0
    begin
      attempts += 1
      video.update_attribute(:state, :transcribing)
      broadcast_video_state(video)
      downloaded_video = URI.open(video.source_download_link)
      puts 'Downloaded Video...'

      output_path = Tempfile.new(['output', "#{video.id}.mp3"]).path
      movie = FFMPEG::Movie.new(downloaded_video.path)
      audio = movie.transcode(output_path, audio_codec: 'mp3')
      puts 'Converted downloaded_video to MP3...'

      response = client.audio.translate(parameters: { model: 'whisper-1', file: File.open(audio.path, 'rb') })
      Transcription.create(video_id: video.id, content: response['text'])
      video.process_video_log.update(transcribed: true)
      video.transcription.reload
    end
  rescue FFMPEG::Error => e
    retry if attempts < 3
    video.update_attribute(:state, :unprocessable)
    broadcast_video_state(video)
  end

  def find_hack(video)
    video.update_attribute(:state, :hacks)
    broadcast_video_state(video)
    Ai::Video.new(video).find_hack!
    video.process_video_log.update(has_hacks: true)
  end

  def find_queries(video)
    video.update_attribute(:state, :queries)
    broadcast_video_state(video)
    Ai::HackProcessor.new(video.hack).find_queries!
    video.process_video_log.update(has_queries: true)
  end

  def broadcast_video_state(video)
    possible_hack = video&.hack&.is_hack? == true
    is_hack = video&.hack&.hack_validation&.status == true
    ActionCable.server.broadcast 'video_state_channel', { id: video.id, state: video.state, possible_hack: possible_hack, is_hack: is_hack }
  end
end
