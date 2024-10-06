require 'json'
require 'pathname'
require_relative 'config'
require_relative 'llm_models'

def load_prompt(*args)
  # Constructs a prompt by loading the content from one or more prompt template files in the prompts directory.

  prompt = ""
  args.each do |file_path|
    File.open(file_path, "r") do |file|
      prompt += file.read.strip
    end
  end
  prompt
end

def verify_hacks_from_text(source_text)
  # Analyzes a piece of text to determine if it constitutes a financial hack, returning a JSON result.

  prompt_template = load_prompt(PROMPTS_TEMPLATES[:HACK_VERIFICATION2])
  format_hash = {source_text: source_text}
  format_hash.default = ''
  prompt = prompt_template % format_hash
  system_prompt = "You are an AI financial analyst tasked with classifying content related to financial strategies."
  puts prompt
  begin
    model = LLMModel.new("gpt-4o-mini")
    result = model.run(prompt, system_prompt)
    
    cleaned_string = result.gsub("```json\n", "").strip
    json_result = JSON.parse(cleaned_string)
    
    return json_result, prompt
  rescue StandardError => e
    puts "Error in verify hacks: #{e.message}"
    return nil, prompt
  end
end