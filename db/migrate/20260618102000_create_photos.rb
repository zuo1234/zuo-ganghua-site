class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.string :image_url, null: false
      t.string :location
      t.date :taken_on
      t.boolean :featured, null: false, default: false
      t.boolean :published, null: false, default: true

      t.timestamps
    end

    add_index :photos, :slug, unique: true
    add_index :photos, [:published, :featured, :taken_on]
  end
end
