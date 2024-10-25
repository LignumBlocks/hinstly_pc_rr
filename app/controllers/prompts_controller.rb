class PromptsController < ApplicationController
  def index
    @prompts = Prompt.all
    @prompt = Prompt.new
    @q = @prompts.ransack(params[:q])
    @pagy, @prompts = pagy(@q.result.order(created_at: :desc), items: 25)
  end

  def show
    @prompt = Prompt.find(params[:id])
    render json: @prompt
  end

  def create
    @prompt = Prompt.new(prompt_params)
    if @prompt.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to prompts_path, notice: 'Prompt was successfully created.' }
      end
    else
      render partial: 'form', locals: { prompt: @prompt }, status: :unprocessable_entity, layout: false
    end
  end

  def update
    @prompt = Prompt.find(params[:id])
    if @prompt.update(prompt_params)
      redirect_to prompts_path, notice: 'Prompt was successfully updated.'
    else
      redirect_to edit_prompt_path(@prompt), alert: 'Prompt not updated'
    end
  end

  def destroy
    @prompt = Prompt.find(params[:id])
    @prompt.destroy
    redirect_to prompts_path, alert: 'Prompt deleted successfully.'
  end

  def new
    @prompt = Prompt.new
    render partial: 'form', locals: { prompt: @prompt }, layout: false
  end

  def edit
    @prompt = Prompt.find(params[:id])
  end

  private

  # Only allow a list of trusted parameters through.
  def prompt_params
    params.require(:prompt).permit(:name, :code, :prompt, :system_prompt)
  end
end