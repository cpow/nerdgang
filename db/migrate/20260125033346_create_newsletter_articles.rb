class CreateNewsletterArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletter_articles do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.integer :position
      t.text :commentary

      t.timestamps
    end

    add_index :newsletter_articles, [:newsletter_id, :article_id], unique: true
  end
end
