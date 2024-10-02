class CreateScrapQueries < ActiveRecord::Migration[7.0]
  def change
    create_table :scrap_queries do |t|
      t.string :question

      t.timestamps
    end
  end
end
