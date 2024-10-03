class CreateChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :channels do |t|
      t.integer :user_id
      t.string :name
      t.string :source
      t.datetime :checked_at
      t.integer :state

      t.timestamps
    end
  end
end
