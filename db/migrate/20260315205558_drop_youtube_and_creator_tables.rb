class DropYoutubeAndCreatorTables < ActiveRecord::Migration[8.1]
  def up
    drop_table :transcript_topics, if_exists: true
    drop_table :transcripts, if_exists: true
    drop_table :trending_topics, if_exists: true
    drop_table :video_snapshots, if_exists: true
    drop_table :ideas, if_exists: true
    drop_table :creator_videos, if_exists: true
    drop_table :creator_channels, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
