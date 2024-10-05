class CreateProcessVideoLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :process_video_logs do |t|
      t.integer :video_id
      t.boolean :transcribed, default: false
      t.boolean :has_hacks, default: false
      t.boolean :has_queries, default: false
      t.boolean :has_scraped_pages, default: false

      t.timestamps
    end
  end
end
