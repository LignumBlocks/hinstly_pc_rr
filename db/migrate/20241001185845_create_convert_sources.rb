class CreateConvertSources < ActiveRecord::Migration[7.0]
  def change
    create_table :convert_sources do |t|

      t.timestamps
    end
  end
end
