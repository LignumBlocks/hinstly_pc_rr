class HackStructuredInfosController < ApplicationController
  def show
    @hack_structured_info = HackStructuredInfo.find(params[:id])
  end
end
