class CreateTrendingTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :trending_topics do |t|
      t.string :name, null: false
      t.string :category
      t.datetime :first_seen_at, null: false
      t.integer :mention_count_7d, default: 0, null: false
      t.integer :mention_count_30d, default: 0, null: false
      t.integer :video_count_7d, default: 0, null: false
      t.float :momentum_score, default: 0.0, null: false
      t.float :performance_correlation

      t.timestamps
    end

    add_index :trending_topics, :name, unique: true
    add_index :trending_topics, :momentum_score
    add_index :trending_topics, :category
  end
end
