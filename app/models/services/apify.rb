module Services
  class Apify
    BASE_URL = 'https://api.apify.com/v2'.freeze
    API_TOKEN = ENV['APIFY_API_TOKEN']
    ACTOR_ID = ENV['APIFY_ACTOR_ID']

    def initialize
      super
    end

    def channel_info(channel_name)
      response = run_actor(channel_name, true)
      data = read_info(response[:data][:defaultDatasetId])

      return nil if data[:error]

      {
        name: channel_name,
        external_source: "tiktok",
        external_source_id: data[:authorMeta][:id],
        avatar: data[:authorMeta][:avatar]
      }
    end

    def download_videos(channel)
      response = run_actor(channel.name)
      binding.pry
    end

    private

    def headers
      {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{API_TOKEN}"
      }
    end

    def run_info(channel_name)
      JSON(HTTParty.post("#{BASE_URL}/acts/#{ACTOR_ID}/runs?token=#{API_TOKEN}&waitForFinish=60", {
        body: body_for_info(channel_name),
        headers: headers
      }).body).deep_symbolize_keys!
    end

    def run_actor(channel_name, wait = false)
      url = "#{BASE_URL}/acts/#{ACTOR_ID}/runs?token=#{API_TOKEN}"
      url += "&waitForFinish=60" if wait

      JSON(HTTParty.post(url, {
        body: body_for_info(channel_name),
        headers: headers
      }).body).deep_symbolize_keys!
    end

    def read_info(dataset_id)
      JSON(HTTParty.get("#{BASE_URL}/datasets/#{dataset_id}/items?token=#{API_TOKEN}", {
        headers: headers
      }).body)[0].deep_symbolize_keys!
    end

    def body_for_info(channel_name)
      {
        "profiles": [channel_name],
        "resultsPerPage": 1,
        "excludePinnedPosts": false,
        "searchSection": "",
        "maxProfilesPerQuery": 3,
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

    def body_for_download(channel_name)
      {
        "profiles": [channel_name],
        "resultsPerPage": 1,
        # "oldestPostDate": from_date,
        "excludePinnedPosts": false,
        "searchSection": "",
        "maxProfilesPerQuery": 1,
        "shouldDownloadVideos": true,
        "shouldDownloadCovers": true,
        "shouldDownloadSubtitles": false,
        "shouldDownloadSlideshowImages": false,
        "maxItems": 1,
        "options": {
          "timeoutSecs": 10000,
          "maxItems": 1
        }
      }.to_json
    end
  end
end
