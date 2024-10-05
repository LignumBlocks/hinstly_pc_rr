class ValidationSourcesController < ApplicationController
  def index
    @validation_sources = ValidationSource.all
    @validation_source = ValidationSource.new
    @q = @validation_sources.ransack(params[:q])
    @pagy, @channels = pagy(@q.result.order(created_at: :desc), items: 25)
  end

  def show
    @validation_source = ValidationSource.find(params[:id])
    render json: @validation_source
  end

  def create
    # Imprime los parámetros recibidos para asegurarte de que son los correctos
    Rails.logger.debug "Parametros recibidos: #{params.inspect}"

    @validation_source = ValidationSource.new(validation_source_params)

    if @validation_source.save
      redirect_to validation_sources_path, notice: "Validation Source create successful!."
    else
      # Si hay errores, renderiza de nuevo la vista index con los errores
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @validation_source = ValidationSource.find(params[:id])
    @validation_source.destroy
    redirect_to validation_sources_path, alert: 'Validation Source deleted successfully.'
  end

  def new
    @validation_source = ValidationSource.new
    render partial: 'form', locals: { validation_source: @validation_source }, layout: false
  end

  def edit
    @validation_source = ValidationSource.find(params[:id])
    render partial: 'form', locals: { validation_source: @validation_source }, layout: false
  end

  private

  def validation_source_params
    params.require(:validation_source).permit(:name, :url_query)
  end
end
