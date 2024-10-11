class CreateHackStructuredInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :hack_structured_infos do |t|
      t.references :hack, null: false, foreign_key: true
      t.string :hack_title
      t.text :description
      t.string :main_goal
      t.text :steps_summary
      t.text :resources_needed
      t.text :expected_benefits
      t.string :extended_title
      t.text :detailed_steps
      t.text :additional_tools_resources
      t.text :case_study

      t.timestamps
    end
  end
end
