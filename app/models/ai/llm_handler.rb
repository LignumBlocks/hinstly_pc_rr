module Ai
  class LlmHandler
    OPENAI_API_KEY = ENV['OPENAI_API_KEY']
    GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']

    MODELS = %w[gpt-4o-mini gpt-3.5-turbo gemini-1.5-flash].freeze

    DEFAULT_SYSTEM_PROMPT = "You are a helpful assistant. Answer all questions to the best of your ability.".freeze

    attr_reader :model_name, :llm

    def initialize(model_name = "gpt-4o-mini", temperature = 0.7)
      @model_name = MODELS.include?(model_name) ? model_name : MODELS[0]
      @temperature = temperature

      if @model_name.include?('gpt')
        @llm = Langchain::LLM::OpenAI.new(api_key: OPENAI_API_KEY, default_options: { temperature: @temperature, chat_completion_model_name: @model_name })
      else
        @llm = Langchain::LLM::GoogleGemini.new(api_key: OPENAI_API_KEY, default_options: {cache: false, temperature: @temperature, chat_completion_model_name: @model_name})
      end
    end

    def run(input, system_prompt = DEFAULT_SYSTEM_PROMPT)
      response = @llm.complete(prompt: system_prompt + input)
      response.completion
      messages = [
        { role: "system", content: system_prompt },
        { role: "user", content: input }
      ]
      response = @llm.chat(messages: messages)
      response.chat_completion
    end
  end
end
