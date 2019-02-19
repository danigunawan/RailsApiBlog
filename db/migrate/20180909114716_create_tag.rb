class CreateTag < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name, unique: true
      t.string :slug, unique: true
      t.text :description
      t.timestamps
    end

    create_table :articles_tags, id: false do |t|
      t.belongs_to :article, index: true, foreign_key: true
      t.belongs_to :tag, index: true, foreign_key: true
    end
  end
end
