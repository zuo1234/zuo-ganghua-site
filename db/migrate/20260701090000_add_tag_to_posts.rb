class AddTagToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :tag, :integer, null: false, default: 0
    add_index :posts, [:tag, :status, :published_at]
  end
end
