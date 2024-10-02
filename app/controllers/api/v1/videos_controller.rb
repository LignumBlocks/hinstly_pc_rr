require 'open-uri'

# delete once we trigger the job from th UI, this is just for local testing
module Api
  module V1
    class VideosController < ApplicationController
      def convert
        url = params[:url]
        job = ExtractHacksJob.perform_later(url: url)

        render json: { status: 'accepted', job_id: job.job_id }, status: :accepted
      end
    end
  end
end
