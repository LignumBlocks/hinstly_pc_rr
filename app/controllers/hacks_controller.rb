require 'open-uri'

class HacksController < ApplicationController
  def index
    @channels = Channel.all
    @total = Hack.all

    @q = current_user.hacks.ransack(params[:q])

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

    hack_filter = params[:filter] || 'valid'

    case hack_filter
    when 'valid'
      @q = current_user.hacks.joins(:hack_structured_info,
                                    :hack_validation).where('hack_validations.status = true').ransack(params[:q])
    when 'not_valid'
      # Mostrar hacks no válidos (sin `hack_structured_info` o con `hack_validations.status = false o NULL`)
      @q = current_user.hacks
                       .left_joins(:hack_structured_info, :hack_validation)
                       .where('hack_structured_infos.id IS NULL OR hack_validations.status = false OR hack_validations.status IS NULL')
                       .ransack(params[:q])
    else
      # Si no hay filtro, mostrar todos los hacks
      @q = current_user.hacks.ransack(params[:q])
    end

    # @q = current_user.hacks.ransack(params[:q])
    @pagy, @hacks = pagy(@q.result.order(created_at: :desc), items: 2)
  end

  def show
    @channel = current_user.channels.where(id: params[:channel_id]).first
    @hack = current_user.hacks.find(params[:id])
  end

  private

  def hack_params
    params.permit(:page, :filter, q: %i[video_channel_id_eq created_at_gteq created_at_lteq])
  end
end
