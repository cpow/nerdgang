class AddUnsubscribeReasonToSubscribers < ActiveRecord::Migration[8.1]
  def change
    add_column :subscribers, :unsubscribe_reason, :string
  end
end
