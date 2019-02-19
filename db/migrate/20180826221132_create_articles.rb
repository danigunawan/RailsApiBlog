class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :slug
      t.string :description
      t.text :body
      t.integer :content_type
      t.integer :views
      t.references :user, index: true, foreign_key: true
      t.timestamps
    end
    add_index :articles, :slug, unique: true
  end
end
