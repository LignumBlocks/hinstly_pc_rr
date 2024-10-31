class AddLinksToScrapToProccessVideoLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :process_video_logs, :has_links_to_scrap, :boolean, default: false
  end
end
