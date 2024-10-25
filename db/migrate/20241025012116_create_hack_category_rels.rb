class CreateHackCategoryRels < ActiveRecord::Migration[7.0]
  def change
    create_table :hack_category_rels do |t|
      t.references :hack, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.text :justification

      t.timestamps
    end
  end
end
