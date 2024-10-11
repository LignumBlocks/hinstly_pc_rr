require 'open-uri'

class HacksController < ApplicationController
  def index
    @q = current_user.hacks.ransack(params[:q])
    @pagy, @hacks = pagy(@q.result.order(created_at: :desc), items: 100)
  end

  def show
    @hack = current_user.hacks.find(params[:id])
  end

  private


  def hack_params
    params.require(:hack).permit(:id)
  end
end