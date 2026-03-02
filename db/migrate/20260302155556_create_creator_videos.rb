class CreateCreatorVideos < ActiveRecord::Migration[8.1]
  def change
    create_table :creator_videos do |t|
      t.references :creator_channel, null: false, foreign_key: true
      t.string :youtube_video_id, null: false
      t.string :title, null: false
      t.text :description
      t.datetime :published_at
      t.integer :duration_seconds
      t.integer :view_count
      t.integer :like_count
      t.integer :comment_count
      t.text :tags

      t.timestamps
    end

    add_index :creator_videos, :youtube_video_id, unique: true
    add_index :creator_videos, :published_at
  end
end
