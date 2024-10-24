class AddTextToVideos < ActiveRecord::Migration[7.0]
  def change
    add_column :videos, :text, :string, default: ''
  end
end
