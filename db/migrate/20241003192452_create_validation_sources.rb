class CreateValidationSources < ActiveRecord::Migration[7.0]
  def change
    create_table :validation_sources do |t|
      t.string :name
      t.string :url_query

      t.timestamps
    end
  end
end
