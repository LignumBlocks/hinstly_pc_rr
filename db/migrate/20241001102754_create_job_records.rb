class CreateJobRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :job_records do |t|
      t.string :job_id
      t.string :status

      t.timestamps
    end
  end
end
