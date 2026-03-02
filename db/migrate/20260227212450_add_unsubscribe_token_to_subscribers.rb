class AddUnsubscribeTokenToSubscribers < ActiveRecord::Migration[8.1]
  def change
    add_column :subscribers, :unsubscribe_token, :string
    add_index :subscribers, :unsubscribe_token, unique: true
    add_column :subscribers, :unsubscribed_at, :datetime
  end
end
