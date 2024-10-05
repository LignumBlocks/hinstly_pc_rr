class CreateScrapedResults < ActiveRecord::Migration[7.0]
  def change
    create_table :scraped_results do |t|
      t.integer :query_id
      t.integer :validation_source_id
      t.string :link
      t.text :content

      t.timestamps
    end
  end
end
