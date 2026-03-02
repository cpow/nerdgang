class CreateVideoSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :video_snapshots do |t|
      t.references :creator_video, null: false, foreign_key: true
      t.datetime :captured_at, null: false
      t.integer :view_count
      t.integer :like_count
      t.integer :comment_count

      t.timestamps
    end

    add_index :video_snapshots, [:creator_video_id, :captured_at]
  end
end
