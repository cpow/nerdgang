class CreateTranscripts < ActiveRecord::Migration[8.1]
  def change
    create_table :transcripts do |t|
      t.references :creator_video, null: false, foreign_key: true
      t.text :content
      t.string :language
      t.boolean :auto_generated, default: false, null: false
      t.integer :word_count
      t.string :processing_status, default: "pending", null: false
      t.datetime :fetched_at

      t.timestamps
    end

    add_index :transcripts, :creator_video_id, unique: true
    add_index :transcripts, :processing_status
  end
end
