class CreateQueries < ActiveRecord::Migration[7.0]
  def change
    create_table :queries do |t|
      t.integer :hack_id
      t.string :content

      t.timestamps
    end
  end
end
