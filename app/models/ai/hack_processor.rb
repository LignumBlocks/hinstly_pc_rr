module Ai
  class HackProcessor
    def initialize(hack)
      @hack = hack
    end

    def find_queries!
      queries = queries_for_hack
      queries.each { |query| @hack.queries.create(content: query) }
    end

    def validate_financial_hack!
      validation = Ai::RagLlmHandler.new('gpt-4o-mini').validation_for_hack(@hack)
      @hack.create_hack_validation!(analysis: validation[:analysis], status: validation[:status], links: validation[:links])
    end

    private

    def queries_for_hack(num_queries = 4)
      prompt = Prompt.find_by_code('GENERATE_QUERIES')
      prompt_text = prompt.build_prompt_text({ num_queries:, hack_title: @hack.title, hack_summary: @hack.summary })
      system_prompt_text = prompt.system_prompt
      model = Ai::LlmHandler.new('gpt-4o-mini')
      result = model.run(prompt_text, system_prompt_text)
      result = result.gsub('json', '').gsub('```', '').strip
      JSON.parse(result)['queries']
    end
  end
end