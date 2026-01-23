class AddDiscardedAtToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :discarded_at, :datetime
    add_index :articles, :discarded_at
  end
end
