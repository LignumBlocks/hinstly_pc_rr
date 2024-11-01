class AddSentToPineconeToScrapedResults < ActiveRecord::Migration[7.0]
  def change
    add_column :scraped_results, :sent_to_pinecone, :boolean, default: false
  end
end
