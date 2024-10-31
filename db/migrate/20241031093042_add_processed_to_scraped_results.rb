class AddProcessedToScrapedResults < ActiveRecord::Migration[7.0]
  def change
    add_column :scraped_results, :processed, :boolean, default: false
  end
end
