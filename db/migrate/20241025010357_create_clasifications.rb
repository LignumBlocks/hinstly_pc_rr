class CreateClasifications < ActiveRecord::Migration[7.0]
  def change
    create_table :clasifications do |t|
      t.string :name

      t.timestamps
    end
  end
end
