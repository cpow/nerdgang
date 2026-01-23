class AddTrackingFieldsToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :bookmarked, :boolean, default: false, null: false
    add_column :articles, :bookmarked_at, :datetime
    add_column :articles, :newsletter_queued, :boolean, default: false, null: false
    add_column :articles, :newsletter_queued_at, :datetime
    add_column :articles, :read_at, :datetime

    add_index :articles, :bookmarked
    add_index :articles, :newsletter_queued
    add_index :articles, :read_at
  end
end
