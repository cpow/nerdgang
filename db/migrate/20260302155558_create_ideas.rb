class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.string :title, null: false
      t.text :angle
      t.string :status, null: false, default: "backlog"
      t.integer :score
      t.text :notes
      t.references :creator_channel, null: false, foreign_key: true
      t.references :creator_video, null: false, foreign_key: true

      t.timestamps
    end

    add_index :ideas, :status
  end
end
