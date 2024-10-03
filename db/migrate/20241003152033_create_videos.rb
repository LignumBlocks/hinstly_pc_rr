class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|
      t.string :state
      t.datetime :processed_at

      t.timestamps
    end
  end
end
