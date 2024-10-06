require 'langchain'
require 'openai'
require 'dotenv'
Dotenv.load

OPENAI_API_KEY = ENV['OPENAI_API_KEY']
GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']

MODELS = ["gpt-4o-mini", "gpt-3.5-turbo", "gemini-1.5-flash"]

class LLMModel
  # A class to manage interactions with different LLMs like OpenAI's GPT or Google's Gemini models.
  # The class supports managing conversations with or without message history.

  attr_reader :model_name, :llm

  def initialize(model_name = "gpt-4o-mini", temperature = 0.7)
    # Initializes the LLMModel with the specified model and temperature.
    @model_name = MODELS.include?(model_name) ? model_name : MODELS[0]
    @temperature = temperature

    # Select the appropriate LLM model
    if @model_name.include?('gpt')
      # @llm = Langchain::LLM::OpenAI.new(api_key: OPENAI_API_KEY, model: @model_name, temperature: @temperature)
      @llm = Langchain::LLM::OpenAI.new(api_key: OPENAI_API_KEY, default_options: { temperature: @temperature, chat_completion_model_name: @model_name })
    else
      # @llm = Langchain::LLM::GoogleGemini.new(model: "gemini-1.5-flash", cache: false, temperature: @temperature)
      @llm = Langchain::LLM::GoogleGemini.new(api_key: OPENAI_API_KEY, default_options: {cache: false, temperature: @temperature, chat_completion_model_name: @model_name})
    end
  end

  def run(input, system_prompt = nil)
    # Executes a conversation with the LLM based on the provided input and optional system prompt.
    
    system_prompt ||= "You are a helpful assistant. Answer all questions to the best of your ability."
    # TODO test if changing from chat to pure LLMs improves the language and removes the extra text
    
    response = @llm.complete(prompt: system_prompt + input)

    puts "Completition response: #{response}"
    response.completion
    messages = [
      { role: "system", content: system_prompt },
      { role: "user", content: input }
    ]
    response = @llm.chat(messages: messages)
    
    puts "Chat response: #{response}"
    response.chat_completion
  end

end