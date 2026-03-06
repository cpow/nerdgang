class AddDetailsToIdeas < ActiveRecord::Migration[8.1]
  def change
    add_column :ideas, :hook, :text
    add_column :ideas, :thumbnail_concept, :string
    add_column :ideas, :key_points, :text
    add_column :ideas, :hardware_components, :string
    add_column :ideas, :difficulty, :string
  end
end
