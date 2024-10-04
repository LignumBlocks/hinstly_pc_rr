class CreateChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :channels do |t|
      t.integer :user_id
      t.string :name
      t.string :external_source
      t.string :external_source_id
      t.datetime :checked_at
      t.integer :state, default: 0

      t.timestamps
    end
  end
end
