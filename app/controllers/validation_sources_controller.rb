class ValidationSourcesController < ApplicationController
  def index
    @validation_sources = ValidationSource.all
    @validation_source = ValidationSource.new
    @q = @validation_sources.ransack(params[:q])
    @pagy, @validation_sources = pagy(@q.result.order(created_at: :desc), items: 25)
  end

  def show
    @validation_source = ValidationSource.find(params[:id])
    render json: @validation_source
  end

  def create
    @validation_source = ValidationSource.new(validation_source_params)
    if @validation_source.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to validation_sources_path, notice: 'Validation Source was successfully created.' }
      end
    else
      render partial: 'form', locals: { validation_source: @validation_source }, status: :unprocessable_entity, layout: false
    end
  end

  def update
    @validation_source = ValidationSource.find(params[:id])
    if @validation_source.update(validation_source_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to validation_sources_path, notice: 'Validation Source was successfully updated.' }
      end
    else
      render partial: 'form', locals: { validation_source: @validation_source }, status: :unprocessable_entity, layout: false
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
