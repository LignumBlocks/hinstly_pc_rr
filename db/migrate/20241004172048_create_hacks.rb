class CreateHacks < ActiveRecord::Migration[7.0]
  def change
    create_table :hacks do |t|
      t.integer :video_id
      t.string :title
      t.string :summary
      t.text :justification
      t.boolean :is_hack

      t.timestamps
    end
  end
end
