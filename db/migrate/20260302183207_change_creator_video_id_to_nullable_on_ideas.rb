class ChangeCreatorVideoIdToNullableOnIdeas < ActiveRecord::Migration[8.1]
  def change
    change_column_null :ideas, :creator_video_id, true
    remove_foreign_key :ideas, :creator_videos
    add_foreign_key :ideas, :creator_videos, on_delete: :nullify
  end
end
