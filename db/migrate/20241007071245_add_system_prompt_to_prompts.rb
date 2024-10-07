class AddSystemPromptToPrompts < ActiveRecord::Migration[7.0]
  def change
    add_column :prompts, :system_prompt, :text
  end
end
