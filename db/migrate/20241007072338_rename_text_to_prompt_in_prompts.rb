class RenameTextToPromptInPrompts < ActiveRecord::Migration[6.1]
  def change
    rename_column :prompts, :text, :prompt
  end
end
