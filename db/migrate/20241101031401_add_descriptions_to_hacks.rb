class AddDescriptionsToHacks < ActiveRecord::Migration[7.0]
  def change
    add_column :hacks, :free_description, :text
    add_column :hacks, :premium_description, :text
  end
end
