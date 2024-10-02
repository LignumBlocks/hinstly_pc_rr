class CreateScrapingResults < ActiveRecord::Migration[7.0]
  def change
    create_table :scraping_results do |t|
      t.integer :scrap_query_id
      t.string :source
      t.string :title
      t.string :description
      t.string :link
      t.text :content
      t.string :job_id

      t.timestamps
    end
  end
end
