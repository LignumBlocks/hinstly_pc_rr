class ChannelsController < ApplicationController
  def index
    @channel = Channel.new
    @q = current_user.channels.ransack(params[:q])
    @pagy, @channels = pagy(@q.result.order(created_at: :desc), items: 25)
  end

  def create
    
  end
end