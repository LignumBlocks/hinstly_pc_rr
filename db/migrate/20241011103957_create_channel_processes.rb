class CreateChannelProcesses < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_processes do |t|
      t.integer :channel_id
      t.integer :count_videos
      t.boolean :finished, default: false

      t.timestamps
    end
  end
end
