class CreateTranscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :transcriptions do |t|
      t.integer :video_id
      t.text :content

      t.timestamps
    end
  end
end
