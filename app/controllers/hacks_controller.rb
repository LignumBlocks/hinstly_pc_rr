class HacksController < ApplicationController
  def show
    @hack = Hack.find(params[:id])

  end
end
