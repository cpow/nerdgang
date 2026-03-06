class CreateTranscriptTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :transcript_topics do |t|
      t.references :transcript, null: false, foreign_key: true
      t.string :name, null: false
      t.string :raw_mention
      t.float :confidence, default: 0.5, null: false
      t.string :category

      t.timestamps
    end

    add_index :transcript_topics, :name
    add_index :transcript_topics, :category
  end
end
