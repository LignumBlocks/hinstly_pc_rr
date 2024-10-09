module Ai
  class BaseHandler
    OPENAI_API_KEY = ENV['OPENAI_API_KEY']
    GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']

    MODELS = %w[gpt-4o-mini gpt-3.5-turbo gemini-1.5-flash].freeze

    DEFAULT_SYSTEM_PROMPT = 'You are a helpful assistant. Answer all questions to the best of your ability.'.freeze

    def initialize(model_name = 'gpt-4o-mini', temperature = 0.7)
      @model_name = MODELS.include?(model_name) ? model_name : MODELS[0]
      @temperature = temperature

      @llm = if @model_name.include?('gpt')
               load_openai
             else
               load_gemini
             end
    end

    def load_openai
      Langchain::LLM::OpenAI.new(
        api_key: OPENAI_API_KEY, default_options: { temperature: @temperature, chat_completion_model_name: @model_name,
                                                    embeddings_model_name: 'text-embedding-3-small' }
      )
    end

    def load_gemini
      Langchain::LLM::GoogleGemini.new(
        api_key: OPENAI_API_KEY,
        default_options: { temperature: @temperature,
                           chat_completion_model_name: @model_name,
                           embeddings_model_name: 'text-embedding-004' }
      )
    end
  end
end