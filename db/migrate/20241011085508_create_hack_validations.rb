class CreateHackValidations < ActiveRecord::Migration[7.0]
  def change
    create_table :hack_validations do |t|
      t.integer :hack_id
      t.text :analysis
      t.boolean :status
      t.string :links

      t.timestamps
    end
  end
end
