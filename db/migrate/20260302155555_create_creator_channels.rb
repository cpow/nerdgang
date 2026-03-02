class CreateCreatorChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :creator_channels do |t|
      t.string :name, null: false
      t.string :handle, null: false
      t.string :youtube_channel_id
      t.text :niche_tags
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :creator_channels, :handle, unique: true
    add_index :creator_channels, :youtube_channel_id
  end
end
