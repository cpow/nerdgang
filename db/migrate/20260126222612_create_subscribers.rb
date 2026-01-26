class CreateSubscribers < ActiveRecord::Migration[8.1]
  def change
    create_table :subscribers do |t|
      t.string :email, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :subscribers, :email, unique: true
    add_index :subscribers, :discarded_at
  end
end
