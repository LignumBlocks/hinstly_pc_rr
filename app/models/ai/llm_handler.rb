module Ai
  class LlmHandler < BaseHandler
    attr_reader :model_name, :llm

    def initialize(model_name = 'gpt-4o-mini', temperature = 0.7)
      super(model_name, temperature)
    end

    # Executes a conversation with the LLM based on the provided input and optional system prompt.
    def run(input, system_prompt = DEFAULT_SYSTEM_PROMPT)
      messages = [
        { role: 'system', content: system_prompt },
        { role: 'user', content: input }
      ]
      response = @llm.chat(messages:)
      response.chat_completion
    end
  end
end
