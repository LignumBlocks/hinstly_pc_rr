class CreateValidationVectors < ActiveRecord::Migration[7.0]
  def change
    create_table :validation_vectors do |t|
      t.text :content
      t.text :namespace
      t.integer :scraped_result_id
    end

    execute <<-SQL
      ALTER TABLE validation_vectors
      ADD COLUMN vectors vector(768);
    SQL
  end
end