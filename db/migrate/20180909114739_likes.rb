class Likes < ActiveRecord::Migration[5.2]
  def change
    create_table :likes do |t|
      t.references :article, index:true, foreign_key: true
      t.references :user, index:true, foreign_key: true
      t.timestamps
    end
    # A user can like once
    add_index :likes, [:user_id, :article_id], unique: true
  end
end
