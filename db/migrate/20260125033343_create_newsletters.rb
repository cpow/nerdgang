class CreateNewsletters < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletters do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.datetime :published_at
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :newsletters, :slug, unique: true
  end
end
