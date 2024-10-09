class Prompt < ApplicationRecord
  def build_prompt_text(tags_to_replace = {})
    prompt_text = prompt.dup
    keys = tags_to_replace.keys
    tags = keys.map { |key| "[{#{key.to_s}}]"}
    tags.each_with_index { |tag, index| prompt_text.gsub!(tag, tags_to_replace[keys[index]].to_s) }

    prompt_text
  end
end
