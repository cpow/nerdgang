class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.string :external_id, null: false
      t.string :source, null: false
      t.string :source_name
      t.string :author
      t.integer :score, default: 0
      t.integer :comments_count, default: 0
      t.datetime :published_at
      t.datetime :scraped_at, null: false
      t.timestamps
    end

    add_index :articles, [:source, :external_id], unique: true
    add_index :articles, :source
    add_index :articles, :published_at
    add_index :articles, :score
  end
end
