class AddAnalyzedToProcessVideoLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :process_video_logs, :analysed, :boolean, default: false
  end
end
