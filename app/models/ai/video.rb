module Ai
  class Video
    def initialize(video)
      @video = video
    end

    def find_hack!
      hack = extract_hack_from_video
      @video.create_hack(title: hack['possible hack title'], summary: hack['brief summary'], justification: hack['justification'], is_hack: hack['is_a_hack'])
      self
    end

    private

    def extract_hack_from_video
      prompt = Prompt.find_by_code('HACK_DISCRIMINATION_REDUCED')
      prompt_text = prompt.build_prompt_text({ source_text: @video.transcription&.content })
      system_prompt_text = prompt.system_prompt
      model = Ai::LlmHandler.new('gpt-4o-mini')
      result = model.run(prompt_text, system_prompt_text)
      result = result.gsub('json', '').gsub('```', '').strip
      JSON.parse(result)
    end
  end
end