class RemoveNewsletterFieldsFromArticles < ActiveRecord::Migration[8.1]
  def change
    remove_column :articles, :newsletter_queued, :boolean
    remove_column :articles, :newsletter_queued_at, :datetime
  end
end
