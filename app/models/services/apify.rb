module Services
  class Apify
    BASE_URL = 'https://api.apify.com/v2'.freeze
    API_TOKEN = ENV['APIFY_API_TOKEN']
    ACTOR_ID = ENV['APIFY_ACTOR_ID']

    def initialize
      super
    end

    def channel_info(channel_name)
      response = run_actor(body_for_info(channel_name), true)
      data = read_dataset(response[:data][:defaultDatasetId])
      return nil if data[0][:error]

      {
        name: channel_name,
        external_source: "tiktok",
        external_source_id: data[0][:authorMeta][:id],
        avatar: data[0][:authorMeta][:avatar]
      }
    end

    def read_dataset(dataset_id)
      items = JSON(HTTParty.get("#{BASE_URL}/datasets/#{dataset_id}/items?token=#{API_TOKEN}", {
        headers: headers
      }).body)
      items.map(&:deep_symbolize_keys!)
      items
    end

    def download_videos(channel)
      response = run_actor(body_for_download(channel))
      run = channel.apify_runs.build({ apify_run_id: response[:data][:id], apify_dataset_id: response[:data][:defaultDatasetId]})
      run.save && channel.update(state: 1)
    end

    private

    def headers
      {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{API_TOKEN}"
      }
    end

    def run_actor(body, wait = false)
      url = "#{BASE_URL}/acts/#{ACTOR_ID}/runs?token=#{API_TOKEN}"
      url += "&waitForFinish=60" if wait
      JSON(HTTParty.post(url, {
        body: body,
        headers: headers
      }).body).deep_symbolize_keys!
    end

    def body_for_info(channel_name)
      {
        "profiles": [channel_name],
        "resultsPerPage": 1,
        "excludePinnedPosts": false,
        "searchSection": "",
        "maxProfilesPerQuery": 1,
        "shouldDownloadVideos": false,
        "shouldDownloadCovers": false,
        "shouldDownloadSubtitles": false,
        "shouldDownloadSlideshowImages": false,
        "maxItems": 1,
        "options": {
          "timeoutSecs": 10000,
          "maxItems": 1
        }
      }.to_json
    end

    def body_for_download(channel, all_videos = false)
      # oldest_post_date = ch
      {
        "profiles": [channel.name],
        "resultsPerPage": 3,
        "excludePinnedPosts": false,
        "searchSection": "",
        "maxProfilesPerQuery": 1,
        "shouldDownloadVideos": true,
        "shouldDownloadCovers": true,
        "shouldDownloadSubtitles": false,
        "shouldDownloadSlideshowImages": false,
        "maxItems": 3,
        "options": {
          "timeoutSecs": 10000,
          "maxItems": 3
        }
      }.to_json
    end
  end
end
