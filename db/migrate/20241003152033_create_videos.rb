class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|
      t.integer :channel_id
      t.integer :state, default: 0
      t.datetime :processed_at
      t.datetime :external_created_at
      t.string :external_source, default: "tiktok"
      t.string :external_source_id
      t.integer :duration
      t.integer :digg_count
      t.integer :comment_count
      t.integer :share_count
      t.integer :play_count
      t.string :source_download_link
      t.string :source_link

      t.timestamps
    end
  end
end
