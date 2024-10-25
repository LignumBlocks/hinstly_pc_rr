class PromptsController < ApplicationController
  before_action :set_prompt, only: %i[show edit update destroy]

  # GET /prompts
  def index
    @prompts = Prompt.all
    @q = @prompts.ransack(params[:q])
    @pagy, @prompts = pagy(@q.result.order(created_at: :desc), items: 25)
  end

  # GET /prompts/1
  def show
  end

  # GET /prompts/new
  def new
    @prompt = Prompt.new
  end

  # GET /prompts/1/edit
  def edit
  end

  # POST /prompts
  def create
    @prompt = Prompt.new(prompt_params)

    if @prompt.save
      redirect_to @prompt, notice: 'Prompt was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /prompts/1
  def update
    if @prompt.update(prompt_params)
      redirect_to @prompt, notice: 'Prompt was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /prompts/1
  def destroy
    @prompt.destroy
    redirect_to prompts_url, notice: 'Prompt was successfully destroyed.', status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_prompt
    @prompt = Prompt.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def prompt_params
    params.fetch(:prompt, {})
  end
end
