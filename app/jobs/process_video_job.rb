require 'open-uri'

class ProcessVideoJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find(video_id)
    client = OpenAI::Client.new

    transcript_video(video, client) unless video.process_video_log.transcribed?
    puts 'Transcribed downloaded_video'

    find_hacks(video, client) unless video.process_video_log.has_hacks?
    puts 'Hacks gotten'

    find_queries(video, client) unless video.process_video_log.has_queries?
    puts 'has queries'

    video.update_attribute(:state, :scraping)
    Services::Scrapper.new(ValidationSource.all, video.queries).scrap!
    video.process_video_log.update(has_scraped_pages: true)

    video.update(state: :processed, processed_at: DateTime.now)
  end

  private

  def transcript_video(video, client)
    video.update_attribute(:state, :transcribing)
    downloaded_video = URI.open(video.source_download_link)
    puts 'Downloaded Video...'

    output_path = Tempfile.new(['output', "#{downloaded_video.path.split('/').last}.mp3"]).path
    movie = FFMPEG::Movie.new(downloaded_video.path)
    audio = movie.transcode(output_path, audio_codec: 'mp3')
    puts 'Converted downloaded_video to MP3...'

    response = client.audio.translate(parameters: { model: 'whisper-1', file: File.open(audio.path, 'rb') })
    Transcription.create(video_id: video.id, content: response['text'])
    video.process_video_log.update(transcribed: true)
    video.transcription.reload
  end

  def find_hacks(video, client)
    video.update_attribute(:state, :generating_hacks)
    response_hacks = client.chat(parameters: { model: 'gpt-4o', messages: [{ role: 'user', content: prompt_for_hacks(video.transcription.content) }], temperature: 0.7 })
    content = response_hacks.dig('choices', 0, 'message', 'content')
    content = content.gsub('json', '').gsub('```', '')
    hacks = JSON.parse(content)['hacks']
    hacks.each do |hack|
      video.hacks.create(title: hack['possible hack title'], summary: hack['brief summary'], justification: hack['justification'],
                         is_hack: hack['is_a_hack'])
    end
    video.process_video_log.update(has_hacks: true)
  end

  def find_queries(video, client)
    video.update_attribute(:state, :generating_queries)
    video.hacks.each do |hack|
      queries_response = client.chat(parameters: { model: 'gpt-4o', messages: [{ role: 'user', content: prompt_for_queries(hack.title, hack.summary) }], temperature: 0.7 })
      content = queries_response.dig('choices', 0, 'message', 'content')
      content = content.gsub('json', '').gsub('```', '')
      queries_for_hack = JSON.parse(content)['queries']
      queries_for_hack.each { |query| hack.queries.create(content: query) }
    end
    video.process_video_log.update(has_queries: true)
  end

  def prompt_for_hacks(source)
    "A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.

      Analize the following content for financial hacks.

      Analize the following content for financial hacks:
      ---
      #{source}
      ---

      The output must be a json with the following structure:
      {\"hacks\": [{
          \"possible hack title\": \"<A consise title of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",
          \"brief summary\": \"<A short description of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",
          \"justification\": \"<Explanation about whether the content includes a valid financial hack>\",
          \"is_a_hack\": \"<Boolean true or false, about whether the content includes a valid financial hack>\"
      }]}
    "
  end

  def prompt_for_queries(hack_title, hack_summary, count = 4)
    "Given the following financial 'hack', generate a set of #{count} relevant queries that allow verifying the validity of the hack. The queries will be used on official financial websites to search for information that can validate or refute the techniques or suggestions of the hack. Make sure to:

    - Use key terms from the hack title and summary when possible.
    - Keep the queries concise and direct, without unnecessary filler words.
    - Formulate the queries in a way that they seek specific information related to the validity of the hack.

    Financial hack title:
    #{hack_title}
    ---
    Financial hack summary:
    #{hack_summary}

    Provide your response only as a JSON object containing a list of the relevant queries, in the following format:

    {
        \"queries\": [ ... ]
    }"
  end
end
