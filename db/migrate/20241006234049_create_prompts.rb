class CreatePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :prompts do |t|
      t.string :name
      t.string :code
      t.text :text

      t.timestamps
    end
  end
end
