class CreateApifyRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :apify_runs do |t|
      t.integer :channel_id
      t.string :apify_run_id
      t.string :apify_dataset_id
      t.integer :state, default: 0

      t.timestamps
    end
  end
end
