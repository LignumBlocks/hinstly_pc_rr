require 'open-uri'

class HacksController < ApplicationController
  def index
    @channels = Channel.all

    # Si el canal no está seleccionado, eliminar el parámetro del filtro
    params[:q].delete(:video_channel_id_eq) if params[:q] && params[:q][:video_channel_id_eq].blank?

    # Convertir las fechas al formato YYYY-MM-DD si están presentes
    if params[:q] && params[:q][:created_at_gteq].present? && params[:q][:created_at_lteq].present?
      begin
        # Convertir la fecha de inicio
        params[:q][:created_at_gteq] = Date.strptime(params[:q][:created_at_gteq], '%m/%d/%Y').strftime('%Y-%m-%d')
        # Convertir la fecha de fin
        params[:q][:created_at_lteq] = Date.strptime(params[:q][:created_at_lteq], '%m/%d/%Y').strftime('%Y-%m-%d')
      rescue ArgumentError
        flash[:alert] = 'Invalid date format'
      end
    end

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
