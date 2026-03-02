class AddSentAtToNewsletters < ActiveRecord::Migration[8.1]
  def change
    add_column :newsletters, :sent_at, :datetime
  end
end
